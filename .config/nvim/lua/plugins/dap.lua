return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local uv = vim.uv or vim.loop

      dapui.setup()

      dap.adapters.go = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "dlv",
          args = {
            "dap",
            "--listen=127.0.0.1:${port}",
            "--log",
            "--log-output=dap",
          },
        },
      }

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
            return candidate, current
          end
          local parent = normalize_dir(vim.fn.fnamemodify(current, ":h"))
          if parent == current then
            break
          end
          current = parent
        end

        return nil, nil
      end

      local function replace_workspace_placeholders(value, workspace_root, workspace_basename)
        if type(value) == "string" then
          value = value:gsub("${workspaceFolderBasename}", workspace_basename)
          return value:gsub("${workspaceFolder}", workspace_root)
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

      local vscode = require("dap.ext.vscode")
      dap.providers.configs["dap.launch.json"] = function(bufnr)
        local start_from = vim.api.nvim_buf_get_name(bufnr)
        local launch_json, workspace_root = find_nearest_launch_json(start_from)
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

        local workspace_basename = vim.fn.fnamemodify(workspace_root, ":t")
        local resolved = {}
        for _, config in ipairs(configs) do
          table.insert(resolved, replace_workspace_placeholders(config, workspace_root, workspace_basename))
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

      local original_run_last = dap.run_last
      dap.run_last = function()
        local session = dap.session()
        if session and session.config and session.config.type == "go" then
          local config = session.config
          dap.terminate({
            on_done = function()
              vim.schedule(function()
                dap.run(config, { new = true })
              end)
            end,
          })
          return
        end
        original_run_last()
      end

      map("<leader>dd", dap.continue, "DAP: start/continue")
      map("<leader>db", dap.toggle_breakpoint, "DAP: toggle breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "DAP: conditional breakpoint")
      map("<leader>dn", dap.step_over, "DAP: step over")
      map("<leader>di", dap.step_into, "DAP: step into")
      map("<leader>do", dap.step_out, "DAP: step out")
      map("<leader>dr", dap.repl.toggle, "DAP: toggle REPL")
      map("<leader>dl", dap.run_last, "DAP: run last")
      map("<leader>dq", dap.terminate, "DAP: terminate")
      map("<leader>du", dapui.toggle, "DAP: toggle UI")

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
