_G.Config = {}
vim.pack.add { "https://github.com/nvim-mini/mini.nvim" }

-- 0.12 的新消息/cmdline 层（ui2）：cmdline 窗口 + 浮动消息窗由它渲染
-- cmdheight=0 必需，否则 cmdline 占一行、ui2 的 msg 窗不起作用
-- 注：cmdline 的补全/autocorrect/范围预览交给 mini.cmdline（纯逻辑层，兼容 ui2）
vim.o.cmdheight = 0
local ui2 = require "vim._core.ui2"
ui2.enable {}
if #vim.api.nvim_list_uis() == 0 then
  -- 无 UI 时 enable() 会直接返回（不阻止 headless 的 stdout 消息）；进 UI 后再开
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function() ui2.enable {} end,
  })
end
-- Loading helpers
local misc = require "mini.misc"
Config.now = function(f) misc.safely("now", f) end
Config.later = function(f) misc.safely("later", f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely("event:" .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely("filetype:" .. ft, f) end
