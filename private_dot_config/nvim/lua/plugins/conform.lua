return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
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

    -- opts.format_on_save = {
    --   timeout_ms = 500,
    --   lsp_format = "fallback",
    -- }
  end,
}
