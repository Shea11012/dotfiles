return {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      require("go").setup {
        capabilities = capabilities,
        lsp_cfg = true,
        lsp_keymaps = function(bufnr)
          local opts = { noremap = true, silent = true, buffer = bufnr }
          local keymaps = {
              --stylua: ignore start
            { key = '<space>rn', func = require('go.rename').run,                                                desc = 'rename' },
            { key = '<space>wa', func = vim.lsp.buf.add_workspace_folder,                                        desc = 'add workspace' },
            { key = '<space>wr', func = vim.lsp.buf.remove_workspace_folder,                                     desc = 'remove workspace' },

            { key = '<space>ca', func = require('go.codeaction').run_code_action,                                desc = 'code action' },
            { key = 'gr',        func = vim.lsp.buf.references,                                                  desc = 'references' },
            -- { key = '<space>e',  func = vim.diagnostic.open_float,                                               desc = 'diagnostic' },
            -- { key = '[d',        func = vim.diagnostic.goto_prev,                                                desc = 'diagnostic prev' },
            -- { key = ']d',        func = vim.diagnostic.goto_next,                                                desc = 'diagnostic next' },
            -- { key = '<space>q',  func = vim.diagnostic.setloclist,                                               desc = 'diagnostic loclist' },


            { key = '<space>ca', func = require('go.codeaction').run_code_action,                                desc = 'range code action',   mode = 'v' },
            { key = '<space>wl', func = function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, desc = 'list workspace' },
            --stylua: ignore end
          }

          for _, keymap in pairs(keymaps) do
            opts.desc = keymap.desc
            if keymap.key == nil or keymap.func == nil then
              vim.notify("invalid keymap" .. vim.inspect(keymap), vim.log.levels.WARN)
              return
            end
            vim.keymap.set(keymap.mode or "n", keymap.key, keymap.func, opts)
          end
        end,
        -- dap_debug_keymap = false,
      }
    end,
    -- event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  }
