if not vim.g.vscode then return {} end

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings
    maps.n["<Leader>ff"] = function() require("vscode-neovim").action "actions.find" end
  end,
}
