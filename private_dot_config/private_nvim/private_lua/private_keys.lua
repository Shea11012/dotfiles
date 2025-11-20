local map_multi = require("mini.keymap").map_multistep
local map_combo = require("mini.keymap").map_combo
-- save file
vim.keymap.set({'n'}, '<leader>w', '<cmd>w<cr>', {desc = "save file"})
-- save file and quit
vim.keymap.set({'n'}, '<leader>q', '<cmd>q<cr>', {desc = "quit"})

-- open file pick window
vim.keymap.set({'n','v'},'<Leader>-','<cmd>Yazi<cr>', { desc = "Open yazi at the current file"})

