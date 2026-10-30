return {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				returnType = { enabled = true },
			},
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				returnType = { enabled = true },
			},
		},
	},
}
