return {
  "goolord/alpha-nvim",
  config = function()
    local status_ok, alpha = pcall(require, "alpha")
    if not status_ok then
      return
    end

    local dashboard = require("alpha.themes.dashboard")

    -- remove mapping buttons and dashboard logo
    dashboard.section.buttons.val = {}
    dashboard.section.header.val = {}

    local quote = {
      type = "group",
      val = {
        {
          type = "text",
          val = {
            [[       ,                              ]],
            [[       \`-._           __             ]],
            [[        \\  \-..____,.'  `.           ]],
            [[         :  )       :      :\         ]],
            [[          ;'        '   ;  | :        ]],
            [[          )..      .. .:.`.; :        ]],
            [[         /::...  .:::...   ` ;        ]],
            [[         `:o>   /\o_>        : `.     ]],
            [[        `-`.__ ;   __..--- /:.   \    ]],
            [[        === \_/   ;=====_.':.     ;   ]],
            [[         ,/'`--'...`--....        ;   ]],
            [[              ;                    ;  ]],
            [[          . '                       ; ]],
            [[        .'     ..     ,      .       ;]],
            [[       :       ::..  /      ;::.     |]],
            [[      /      `.;::.  |       ;:..    ;]],
            [[     :         |:.   :       ;:.    ; ]],
            [[     :         ::     ;:..   |.    ;  ]],
            [[      :       :;      :::....|     |  ]],
            [[      /\     ,/ \      ;:::::;     ;  ]],
            [[    .:. \:..|    :     ; '.--|     ;  ]],
            [[   ::.  :''  `-.,,;     ;'   ;     ;  ]],
            [[.-'. _.'\      / `;      \,__:      \ ]],
            [[`---'    `----'   ;      /    \,.,,,/ ]],
            [[                   `----`             ]],
            [[                                      ]]
          },
          opts = { position = "center", },
        },
      },
    }

    -- add spacing before content
    table.insert(dashboard.config.layout, 1, {
      type = "padding",
      val = math.floor(vim.o.lines * 0.1),
    })

    table.insert(dashboard.config.layout, #dashboard.config.layout, quote)

    alpha.setup(dashboard.config)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.keymap.set("n", "<CR>", "<Nop>", { buffer = true, silent = true })
      end,
    })
  end,
}
