return {
  name = "Caddy sever",
  builder = function()
    local cwd = vim.fn.getcwd()
    return {
      cmd = { "caddy", "file-server", "-r", cwd, "-l", ":8080", "-b" },
      cwd = cwd,
      components = {
        "default",
      },
    }
  end,
  condition = {
    filetype = { "html", "css", "js" },
  },
}
