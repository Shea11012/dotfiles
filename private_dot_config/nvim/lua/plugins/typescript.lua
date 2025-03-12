--- 使用biomejs 代替 eslint prettierd
return {
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      if opts.autocmds.eslint_fix_one_save then opts.autocmds.eslint_fix_one_save = nil end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "biome" })
      opts.handlers.eslint = nil
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      if opts.handlers.prettierd then opts.handlers.prettierd = nil end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local format_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
      for _, ft in ipairs(format_filetypes) do
        opts.formatters_by_ft[ft] = {}
      end
    end,
  },
}
