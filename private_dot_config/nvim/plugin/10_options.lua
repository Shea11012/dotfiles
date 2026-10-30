vim.o.relativenumber = true
vim.o.cursorline = false
vim.o.clipboard = "unnamedplus"
if vim.env.SSH_TTY then
	vim.o.clipboard = ""
end
