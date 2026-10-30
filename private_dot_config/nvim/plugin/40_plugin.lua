local add = vim.pack.add
local now_if_args, later, on_filetype = Config.now_if_args, Config.later, Config.on_filetype
local gh = function(p)
	return "https://github.com/" .. p
end

later(function()
	require("im-switch").setup()
end)

now_if_args(function()
	add({ gh("folke/tokyonight.nvim") })
	vim.cmd("colorscheme tokyonight-moon")
end)

later(function()
	add({ gh("mikavilpas/yazi.nvim"), gh("nvim-lua/plenary.nvim") })
	require("yazi").setup({})
end)

-- completion
now_if_args(function()
	add({ gh("Saghen/blink.lib"), gh("Saghen/blink.cmp") })

	local cmp = require("blink.cmp")

	-- v2 的 native fuzzy 库需要本地编译一次（cargo）；已构建过时是 no-op
	cmp.build():pwait()

	cmp.setup({
		-- 'super-tab'：Tab 接受当前项（没选中则选第一个再接受），snippet 活跃时先跳占位符
		keymap = { preset = "super-tab" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 300 },
		},
		signature = { enabled = true },
		sources = { default = { "lsp", "path", "snippets", "buffer" } },
		-- cmdline 补全交给 mini.cmdline（避免两套补全抢 builtin pum）
		cmdline = { enabled = false },
	})

	-- 把 blink 的补全能力告诉所有 LSP server（要在 client 启动前设置）
	vim.lsp.config("*", { capabilities = cmp.get_lsp_capabilities() })
end)

-- picker
now_if_args(function()
	add({ gh("folke/snacks.nvim") })

	require("snacks").setup({
		picker = { enabled = true },
		-- 只启用 picker，其余模块全部关掉
		bigfile = { enabled = false },
		explorer = { enabled = false },
		git = { enabled = false },
		gitbrowse = { enabled = false },
		indent = { enabled = false },
		input = { enabled = false },
		lazygit = { enabled = false },
		notifier = { enabled = false },
		profiler = { enabled = false },
		quickfile = { enabled = false },
		scope = { enabled = false },
		scratch = { enabled = false },
		statuscolumn = { enabled = false },
		terminal = { enabled = false },
		words = { enabled = false },
		zen = { enabled = false },
	})
end)

-- format
later(function()
	add({ gh("stevearc/conform.nvim") })

	require("conform").setup({
		default_format_opts = {
			-- Allow formatting from LSP server if no dedicated formatter is available
			lsp_format = "fallback",
		},
		-- Map of filetype to formatters
		formatters_by_ft = {
			javascript = { "biome" },
			javascriptreact = { "biome" },
			typescript = { "biome" },
			typescriptreact = { "biome" },
			json = { "biome" },
			jsonc = { "biome" },
			lua = { "stylua" },
			python = { "ruff_format" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	})
end)
