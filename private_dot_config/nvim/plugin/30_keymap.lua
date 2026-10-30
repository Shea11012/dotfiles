local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("-", "<cmd>Yazi<cr>", "Open yazi at current file")

-- 文件/buffer
nmap_leader("w", "<cmd>write<cr>", "Save file")
nmap_leader("q", "<cmd>quit<cr>", "quit")

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer: previous" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Buffer: next" })
nmap_leader("bd", function()
	require("mini.bufremove").delete(0, false)
end, "Buffer: delete current")

-- lsp（gd / grn / gra / grr / gri / K / gO 用 Neovim 0.11+ 的内置默认）
local picker = function(name, opts)
	return function()
		require("snacks").picker[name](opts)
	end
end

nmap_leader("la", vim.lsp.buf.code_action, "LSP: code action")
nmap_leader("lr", vim.lsp.buf.rename, "LSP: rename symbol")
nmap_leader("lf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "LSP: format buffer")
nmap_leader("ld", picker("diagnostics_buffer"), "LSP: diagnostics (buffer)")
nmap_leader("lD", picker("diagnostics"), "LSP: diagnostics (all)")
nmap_leader("ls", picker("lsp_symbols"), "LSP: symbols (document)")
nmap_leader("lS", picker("lsp_workspace_symbols"), "LSP: symbols (workspace)")
nmap_leader("lR", picker("lsp_references"), "LSP: references")
-- 跳转（snacks picker：单目标直接跳，多目标弹列表；<C-]> 仍然走 'tagfunc' 的 definition）
nmap_leader("lgd", picker("lsp_definitions"), "LSP: definition")
nmap_leader("lgD", picker("lsp_declarations"), "LSP: declaration")
nmap_leader("lgi", picker("lsp_implementations"), "LSP: implementation")
nmap_leader("lgt", picker("lsp_type_definitions"), "LSP: type definition")

-- picker（snacks.nvim）
nmap_leader("fn", picker("notifications"), "Picker: notifications history")
nmap_leader("ff", picker("files"), "Picker: files")
nmap_leader("fg", picker("grep"), "Picker: grep")
nmap_leader("fw", picker("grep_word"), "Picker: grep word under cursor")
nmap_leader("fb", picker("buffers"), "Picker: buffers")
nmap_leader("fr", picker("recent"), "Picker: recent files")
nmap_leader("fh", picker("help"), "Picker: help")
nmap_leader("fk", picker("keymaps"), "Picker: keymaps")
nmap_leader("fq", picker("qflist"), "Picker: quickfix")
nmap_leader("fl", picker("lines"), "Picker: lines (current buffer)")
nmap_leader("f.", picker("resume"), "Picker: resume last")

-- treesitter textobjects
local textobj = function(mod, fn, query)
	return function()
		require("nvim-treesitter-textobjects." .. mod)[fn](query, "textobjects")
	end
end

-- 选择：a/f（外）、i（内）
for _, m in ipairs({
	{ "af", "@function.outer", "Select function (outer)" },
	{ "if", "@function.inner", "Select function (inner)" },
	{ "ac", "@class.outer", "Select class (outer)" },
	{ "ic", "@class.inner", "Select class (inner)" },
	{ "ao", "@loop.outer", "Select loop (outer)" },
	{ "io", "@loop.inner", "Select loop (inner)" },
	{ "ai", "@conditional.outer", "Select conditional (outer)" },
	{ "ii", "@conditional.inner", "Select conditional (inner)" },
	{ "ab", "@block.outer", "Select block (outer)" },
	{ "ib", "@block.inner", "Select block (inner)" },
}) do
	vim.keymap.set({ "x", "o" }, m[1], textobj("select", "select_textobject", m[2]), { desc = m[3] })
end

-- 跳转
for _, m in ipairs({
	{ "]f", "goto_next_start", "@function.outer", "Next function start" },
	{ "[f", "goto_previous_start", "@function.outer", "Prev function start" },
	{ "]F", "goto_next_end", "@function.outer", "Next function end" },
	{ "[F", "goto_previous_end", "@function.outer", "Prev function end" },
	{ "]c", "goto_next_start", "@class.outer", "Next class start" },
	{ "[c", "goto_previous_start", "@class.outer", "Prev class start" },
	{ "]o", "goto_next_start", { "@loop.inner", "@loop.outer" }, "Next loop start" },
	{ "[o", "goto_previous_start", { "@loop.inner", "@loop.outer" }, "Prev loop start" },
}) do
	vim.keymap.set({ "n", "x", "o" }, m[1], textobj("move", m[2], m[3]), { desc = m[4] })
end
