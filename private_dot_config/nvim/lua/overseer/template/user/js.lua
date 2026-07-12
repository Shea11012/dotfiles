return {
  name = "run js",
  builder = function()
    local cwd = vim.fn.getcwd()
    local file = vim.fn.expand("%:t")
    return {
      cmd = { "node", file},
      cwd = cwd,
      components = {
        "default",
        {"open_output",on_start = "always"}
      },
    }
  end,
  condition = {
    filetype = { "javascript" },
  },
}
