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
      local dapgo = require("dap-go")

      dapui.setup()
      dapgo.setup()

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

      local function load_env_file(path)
        local env = {}
        local ok, lines = pcall(vim.fn.readfile, path)
        if not ok then
          return env
        end
        for _, line in ipairs(lines) do
          local s = line:gsub("^%s+", ""):gsub("%s+$", "")
          if s ~= "" and not s:match("^#") then
            local key, value = s:match("^export%s+([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
            if not key then
              key, value = s:match("^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
            end
            if key then
              value = value:gsub("^%s+", ""):gsub("%s+$", "")
              value = value:gsub("^\"(.*)\"$", "%1"):gsub("^'(.*)'$", "%1")
              env[key] = value
            end
          end
        end
        return env
      end

      local function upsert_config(filetype, name, config)
        dap.configurations[filetype] = dap.configurations[filetype] or {}
        local configs = dap.configurations[filetype]
        for i, existing in ipairs(configs) do
          if existing.name == name then
            configs[i] = config
            return
          end
        end
        table.insert(configs, config)
      end
      local function remove_config(filetype, name)
        local configs = dap.configurations[filetype]
        if not configs then
          return
        end
        for i = #configs, 1, -1 do
          if configs[i].name == name then
            table.remove(configs, i)
          end
        end
      end

      local workspace_default_go_name = "Debug API Server (workspace default)"
      local function refresh_go_workspace_config()
        remove_config("go", workspace_default_go_name)

        local root = vim.fn.getcwd()
        local api_dir = root .. "/api-server"
        local server_dir = api_dir .. "/cmd/server"
        if vim.fn.isdirectory(api_dir) ~= 1 or vim.fn.isdirectory(server_dir) ~= 1 then
          return
        end

        upsert_config("go", workspace_default_go_name, {
          name = workspace_default_go_name,
          type = "go",
          request = "launch",
          console = "internalConsole",
          outputMode = "remote",
          stopOnEntry = true,
          program = function()
            return vim.fn.getcwd() .. "/api-server/cmd/server"
          end,
          cwd = function()
            return vim.fn.getcwd() .. "/api-server"
          end,
          env = function()
            return load_env_file(vim.fn.getcwd() .. "/.env")
          end,
          args = {},
        })
      end

      refresh_go_workspace_config()

      local workspace_dap_group = vim.api.nvim_create_augroup("WorkspaceDapConfig", { clear = true })
      vim.api.nvim_create_autocmd("DirChanged", {
        group = workspace_dap_group,
        callback = function()
          refresh_go_workspace_config()
        end,
      })

      local flutter_adapter = vim.fn.stdpath("config") .. "/scripts/flutter_dap_adapter.py"
      if vim.fn.filereadable(flutter_adapter) == 1 and vim.fn.executable("flutter") == 1 then
        dap.adapters.dart = {
          type = "executable",
          command = flutter_adapter,
        }
      elseif vim.fn.executable("flutter") == 1 then
        dap.adapters.dart = {
          type = "executable",
          command = "flutter",
          args = { "--suppress-analytics", "debug_adapter" },
        }
      else
        dap.adapters.dart = {
          type = "executable",
          command = "dart",
          args = { "debug_adapter" },
        }
      end

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end

      map("<leader>dd", function()
        refresh_go_workspace_config()
        dap.continue()
      end, "DAP: start/continue")
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
