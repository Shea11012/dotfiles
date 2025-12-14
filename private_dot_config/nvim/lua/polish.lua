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

local nu_shell_options = {
  sh = "nu",
  shellslash = true,
  shellcmdflag = "--stdin --no-newline -c",
  shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --froce --raw %s } | into record",
  shellquote = "",
  shellredir = "out+err> %s",
  shelltemp = false,
  shellxescape = "",
  shellxquote = "",
}

local function set_options(options)
  for k, v in pairs(options) do
    vim.opt[k] = v
  end
end

if vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 then
  set_options(nu_shell_options)
  -- if vim.o.shell:find("bash", 1) then vim.o.shellcmdflag = "-s" end
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
end

-- vim.on_key(function(char)
--   if vim.fn.mode() == "n" then
--     local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
--     if vim.opt.hlsearch ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
--   end
-- end, vim.api.nvim_create_namespace "auto_hlsearch")

vim.opt.iskeyword:append "-"

local im_switch = require "utils.im-switch"
im_switch.setup()
