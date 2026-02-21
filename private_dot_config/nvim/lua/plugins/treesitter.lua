local ensure_installed ={
  "bash",
  "c",
  "css",
  "diff",
  "gitcommit",
  "html",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "query",
  "vimdoc",
  "vim",
  "json",
  "yaml",
  "rust",
  "go",
  "javascript",
  "http",
}
return {
    "AstroNvim/astrocore",
    opts = {
        treesitter = {
            highlight = true,
            indent = true,
            auto_install = true,
            ensure_installed = ensure_installed,
        }
    }
}
