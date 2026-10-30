return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      -- Neovim 内置的是 LuaJIT
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      workspace = {
        -- 让 lua_ls 认识 vim.* / 插件里的 API
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      diagnostics = {
        globals = { "vim", "Config" },
      },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
}
