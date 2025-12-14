-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- import/override with your plugins folder
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.recipes.vscode-icons" },

  -- interaction with vscode
  { import = "astrocommunity.recipes.vscode" },

  -- editing
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.utility.noice-nvim" },

  { import = "astrocommunity.editing-support.conform-nvim" },
  { import = "astrocommunity.code-runner.overseer-nvim" },
  -- test
  { import = "astrocommunity.test.neotest" },

  -- languages
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.python-ruff" },

  -- debug
  { import = "astrocommunity.debugging.nvim-dap-virtual-text" },
}
