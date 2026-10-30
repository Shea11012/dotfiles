require("mini.basics").setup({
	options = {
		extra_ui = true,
	},
})

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
Config.later(MiniIcons.tweak_lsp_kind)

local starter = require("mini.starter")
starter.setup({
	evaluate_signle = true,
	items = {
		starter.sections.builtin_actions(),
		starter.sections.recent_files(10, false),
	},
	content_hooks = {
		starter.gen_hook.adding_bullet(),
		starter.gen_hook.indexing("all", { "builtin_actions" }),
		starter.gen_hook.padding(3, 2),
	},
})

require("mini.pairs").setup()
require("mini.surround").setup()

-- cmdline：自动补全（builtin pum）+ 命令名 autocorrect + 范围预览（autopeek）
-- 与 0.12 的 ui2 兼容（它只管补全，不管 cmdline 外观）
require("mini.cmdline").setup()

-- 按键提示（代替 which-key）：需要显式 triggers 才会弹窗
require("mini.clue").setup({
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "z" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "\\" },
	},
	clues = {
		-- 自己的 group
		{ mode = "n", keys = "<Leader>l", desc = "+LSP" },
		{ mode = "n", keys = "<Leader>f", desc = "+Picker" },
		-- 内置常见键的提示集
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.z(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.marks(),
	},
	window = { delay = 300 },
})

-- picker 交给 snacks.nvim（它同时接管 vim.ui.select）；mini.pick/mini.extra 不再启用

require("mini.statuscolumn").setup()
require("mini.statusline").setup()
require("mini.tabline").setup()
