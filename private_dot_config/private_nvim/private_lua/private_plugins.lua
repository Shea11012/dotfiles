local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function() require("mini.basics").setup({
  options = {
    basic = true,
    extra_ui = true,
    win_borders = "auto",
  },
  autocommands = {
   basic = true,
   relnum_in_visual_mode = true,
  }
}) end)
now(function() 
local miniclue = require('mini.clue')
miniclue.setup({
triggers = {
    -- Leader triggers
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- Marks
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}) end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.tabline').setup() end)
now(function() require('mini.statusline').setup() end)
now(function() require('mini.keymap').setup() end)

now(function() 
  add({ source = "catppuccin/nvim", name = "catppuccin" })
  require("catppuccin").setup()

  vim.o.termguicolors = true
  vim.cmd('colorscheme catppuccin-macchiato')
end)

now(function()
  add({
    source = "mikavilpas/yazi.nvim",
    depends = {"nvim-lua/plenary.nvim"},
    name = "yazi"
  })

  require("yazi").setup()
end
)
