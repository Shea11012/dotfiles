-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "json",
      "yaml",
      "rust",
      "go",
      "javascript",
      "http",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
