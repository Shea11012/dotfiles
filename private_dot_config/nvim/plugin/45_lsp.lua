local add, later = vim.pack.add, Config.later
local gh = function(p)
	return "https://github.com/" .. p
end

-- lsp/<server>.lua -> mason 包名
local servers = {
	gopls = "gopls",
	lua_ls = "lua-language-server",
	rust_analyzer = "rust-analyzer",
	basedpyright = "basedpyright",
	vtsls = "vtsls",
	jsonls = "json-lsp",
}

vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = true },
	virtual_text = { spacing = 2, source = "if_many" },
	jump = { float = true },
})

-- 从 lsp/<server>.lua 里取出可执行文件名
local function server_cmd(server)
	local cfg = vim.lsp.config[server] or {}
	local cmd = cfg.cmd
	if type(cmd) == "table" then
		cmd = cmd[1]
	end
	return type(cmd) == "string" and cmd or nil
end

local registry

local function mason_installed(pkg_name)
	return registry ~= nil and registry.has_package(pkg_name) and registry.get_package(pkg_name):is_installed()
end

-- 重复调用是幂等的；只 enable 已经能正常启动的 server，
-- 否则 `cmd` 解析失败会在每次打开 buffer 时刷一条错误
local function enable()
	local ready = {}
	for server, pkg_name in pairs(servers) do
		local cmd = server_cmd(server)
		if cmd and (mason_installed(pkg_name) or vim.fn.executable(cmd) == 1) then
			ready[#ready + 1] = server
		end
	end

	if #ready > 0 then
		vim.lsp.enable(ready)
	end
end

later(function()
	add({ gh("mason-org/mason.nvim") })

	-- 会把 mason 的 bin 目录前置到 PATH
	require("mason").setup({ ui = { border = "rounded" } })

	local ok
	ok, registry = pcall(require, "mason-registry")
	if ok then
		-- 缺的 server 交给 mason 异步安装，装好一个 enable 一个
		registry.refresh(function()
			for _, pkg_name in pairs(servers) do
				if registry.has_package(pkg_name) then
					local pkg = registry.get_package(pkg_name)
					if not pkg:is_installed() then
						pkg:install()
					end
				end
			end
		end)

		registry:on("package:install:success", enable)
	end

	enable()
end)
