local M = {}

local ascii_mode =
  { "busctl", "call", "--user", "org.fcitx.Fcitx5", "/rime", "org.fcitx.Fcitx.Rime1", "SetAsciiMode", "b", "true" }
local zh_mode =
  { "busctl", "call", "--user", "org.fcitx.Fcitx5", "/rime", "org.fcitx.Fcitx.Rime1", "SetAsciiMode", "b", "false" }

local function is_linux()
  local os_name = vim.loop.os_uname().sysname
  return os_name == "Linux"
end

local function set_ascii_mode(ascii)
  local cmd = ascii and ascii_mode or zh_mode
  local ok, _ = pcall(vim.fn.system, cmd)
  if not ok or vim.v.shell_error ~= 0 then vim.notify("Fcitx5 Rime mode switch failed", vim.log.levels.WARN) end
end

function M.setup()
  if not is_linux() then return end
  local group = vim.api.nvim_create_augroup("FcitxRimeToggle", { clear = true })

  vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
    group = group,
    callback = function() set_ascii_mode(true) end,
  })

  vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
    group = group,
    callback = function() set_ascii_mode(false) end,
  })
end

return M
