-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
local function paste()
  return {
    vim.fn.split(vim.fn.getreg "", "\n"),
    vim.fn.getregtype "",
  }
end

-- 使用OSC52可以将剪贴板内容复制到本地
if vim.env.SSH_TTY then
  vim.o.clipboard = "unnamedplus"
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy "+",
      ["*"] = require("vim.ui.clipboard.osc52").copy "*",
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end

-- if vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 then
--   vim.o.shell = "nu"
--   -- Setting shell command flags
--   vim.o.shellcmdflag = ""
--
--   -- Setting shell redirection
--   vim.o.shellredir = ""
--
--   -- Setting shell pipe
--   vim.o.shellpipe = ""
--
--   -- Setting shell quote options
--   vim.o.shellquote = ""
--   vim.o.shellxquote = ""
--   -- vim.o.shellslash = true
-- end
