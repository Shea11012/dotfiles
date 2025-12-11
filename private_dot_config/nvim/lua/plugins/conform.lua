return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "biome" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "biome" })
    end,
  },
  "stevearc/conform.nvim",
  opts = function(_, opts)
    if not opts.formatters_by_ft then opts.formatters_by_ft = {} end
    -- biome
    local biome_ft = {
      "astro",
      "css",
      "graphql",
      "javascript",
      "javascriptreact",
      "json",
      "jsonc",
      "svelte",
      "typescript",
      "typescriptreact",
      "vue",
    }
    for _, ft in pairs(biome_ft) do
      opts.formatters_by_ft[ft] = { "biome-organize-imports", "biome" }
    end
    opts.formatters_by_ft["go"] = { "goimports", "gofumpt" }
    opts.formatters_by_ft["http"] = { "kulala-fmt" }
    opts.formatters_by_ft["lua"] = { "stylua" }
  end,
}
