return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local uv = vim.uv or vim.loop

      dap.adapters.go = function(callback, client_config)
        local host = (client_config and client_config.host) or "127.0.0.1"
        local port = (client_config and client_config.port) or "${port}"
        callback({
          type = "server",
          host = host,
          port = port,
          executable = {
            command = "dlv",
            args = {
              "dap",
              "-l",
              string.format("%s:%s", host, tostring(port)),
              "--log",
              "--log-output=dap",
            },
            detached = vim.fn.has("win32") == 0,
          },
          options = {
            initialize_timeout_sec = 20,
          },
        })
      end
      dap.adapters.delve = dap.adapters.go

      local function path_type(path)
        local stat = uv.fs_stat(path)
        if not stat then
          return nil
        end
        return stat.type
      end

      local function normalize_dir(path)
        local normalized = vim.fn.fnamemodify(path, ":p")
        if normalized ~= "/" then
          normalized = normalized:gsub("/+$", "")
        end
        return normalized
      end

      local function find_nearest_launch_json(start_from)
        local current = start_from
        if current == "" then
          current = vim.fn.getcwd()
        end

        if path_type(current) == "file" then
          current = vim.fn.fnamemodify(current, ":h")
        end
        current = normalize_dir(current)

        while current ~= "" do
          local candidate = current .. "/.vscode/launch.json"
          if path_type(candidate) == "file" then
            return candidate
          end
          local parent = normalize_dir(vim.fn.fnamemodify(current, ":h"))
          if parent == current then
            break
          end
          current = parent
        end

        return nil
      end

      local function replace_workspace_placeholders(value, workspace_root, workspace_basename)
        if type(value) == "string" then
          value = value:gsub("${workspaceFolderBasename}", workspace_basename)
          value = value:gsub("${workspaceFolder}", workspace_root)
          return value:gsub("${workspaceRoot}", workspace_root)
        end
        if type(value) ~= "table" then
          return value
        end

        local resolved = {}
        for key, item in pairs(value) do
          resolved[key] = replace_workspace_placeholders(item, workspace_root, workspace_basename)
        end
        return setmetatable(resolved, getmetatable(value))
      end

      local function parse_env_file(env_path)
        local vars = {}
        if path_type(env_path) ~= "file" then
          return vars
        end

        local fp = io.open(env_path, "r")
        if not fp then
          return vars
        end

        for line in fp:lines() do
          local trimmed = vim.trim(line)
          if trimmed ~= "" and not vim.startswith(trimmed, "#") then
            trimmed = trimmed:gsub("^export%s+", "")
            local key, value = trimmed:match("^([%w_][%w_%.-]*)%s*=%s*(.*)$")
            if key then
              if #value >= 2 then
                local first = value:sub(1, 1)
                local last = value:sub(-1)
                if (first == '"' and last == '"') or (first == "'" and last == "'") then
                  value = value:sub(2, -2)
                end
              end
              vars[key] = value
            end
          end
        end

        fp:close()
        return vars
      end

      local function apply_env_file(config, workspace_root)
        local env_file = config.envFile
        if type(env_file) ~= "string" or env_file == "" then
          return config
        end

        if not env_file:match("^/") then
          env_file = normalize_dir(workspace_root .. "/" .. env_file)
        end

        local env_from_file = parse_env_file(env_file)
        if next(env_from_file) ~= nil then
          config.env = vim.tbl_extend("force", env_from_file, config.env or {})
        end

        config.envFile = nil
        return config
      end

      local function normalize_go_output_mode(config)
        if type(config) ~= "table" then
          return config
        end
        if (config.type == "go" or config.type == "delve") and config.outputMode == nil then
          -- Delve emits program output as DAP events reliably in remote mode.
          config.outputMode = "remote"
        end
        return config
      end

      local vscode = require("dap.ext.vscode")
      dap.providers.configs["dap.launch.json"] = function(bufnr)
        local start_from = vim.api.nvim_buf_get_name(bufnr)
        local launch_json = find_nearest_launch_json(start_from)
        if not launch_json then
          return {}
        end

        local ok, configs = pcall(vscode.getconfigs, launch_json)
        if not ok then
          vim.notify_once("Can't get configurations from launch.json:\n" .. tostring(configs), vim.log.levels.WARN, {
            title = "DAP",
          })
          return {}
        end

        local workspace_root = normalize_dir(vim.fn.fnamemodify(launch_json, ":h:h"))
        local workspace_basename = vim.fn.fnamemodify(workspace_root, ":t")
        local resolved = {}
        for _, config in ipairs(configs) do
          local item = replace_workspace_placeholders(config, workspace_root, workspace_basename)
          item = apply_env_file(item, workspace_root)
          item = normalize_go_output_mode(item)
          table.insert(resolved, item)
        end
        return resolved
      end

      local flutter_bin = vim.fn.exepath("flutter")
      local dart_bin = vim.fn.exepath("dart")
      local fvm_default_bin = vim.fn.expand("~") .. "/fvm/default/bin"
      local function env_list(extra_env)
        local merged = vim.tbl_extend("force", vim.fn.environ(), extra_env or {})
        local items = {}
        for key, value in pairs(merged) do
          if type(key) == "string" and not key:find("=") and value ~= nil then
            items[#items + 1] = key .. "=" .. tostring(value)
          end
        end
        return items
      end

      if flutter_bin == "" and path_type(fvm_default_bin .. "/flutter") == "file" then
        flutter_bin = fvm_default_bin .. "/flutter"
      end
      if dart_bin == "" and path_type(fvm_default_bin .. "/dart") == "file" then
        dart_bin = fvm_default_bin .. "/dart"
      end

      if flutter_bin ~= "" then
        dap.adapters.dart = {
          type = "executable",
          command = flutter_bin,
          args = { "--suppress-analytics", "debug_adapter" },
          options = {
            env = env_list({
              CI = "true",
              FLUTTER_SUPPRESS_ANALYTICS = "true",
            }),
          },
        }
      elseif dart_bin ~= "" then
        dap.adapters.dart = {
          type = "executable",
          command = dart_bin,
          args = { "debug_adapter" },
        }
      end

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end

      map("<leader>dd", dap.continue, "DAP: start/continue")
      map("<leader>dl", dap.step_over, "DAP: step over")
      map("<leader>dj", dap.step_into, "DAP: step into")
      map("<leader>dk", dap.step_out, "DAP: step out")
      map("<leader>dh", dap.step_back, "DAP: step back")
      map("<leader>db", dap.toggle_breakpoint, "DAP: toggle breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "DAP: conditional breakpoint")
      map("<leader>dr", dap.repl.toggle, "DAP: toggle REPL")
      map("<leader>dn", dap.run_last, "DAP: run last")
      map("<leader>dq", dap.terminate, "DAP: terminate")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: toggle UI" })

      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
