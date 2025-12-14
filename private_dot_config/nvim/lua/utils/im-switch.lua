local M = {}

local ascii_mode =
  { "busctl", "call", "--user", "org.fcitx.Fcitx5", "/rime", "org.fcitx.Fcitx.Rime1", "SetAsciiMode", "b", "true" }
local zh_mode =
  { "busctl", "call", "--user", "org.fcitx.Fcitx5", "/rime", "org.fcitx.Fcitx.Rime1", "SetAsciiMode", "b", "false" }

local function is_linux()
  local os_name = vim.loop.os_uname().sysname
  return os_name == "Linux"
end

local function is_normal_text_buffer()
  local buf = 0 -- 当前buffer
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
  local buflisted = vim.api.nvim_get_option_value("buflisted", { buf = buf })

  if buftype ~= "" and buftype ~= "acwrite" then return false end

  -- 排除常见非文本
  local non_text_filetypes = {
    git = true,
    diff = true,
    help = true,
    dashboard = true,
    packer = true,
    telescope = true,
    [""] = false,
  }

  if non_text_filetypes[filetype] then return false end

  -- 排除未列入buffer列表的buffer
  if not buflisted then return false end

  return true
end

local function set_ascii_mode(ascii)
  if not is_normal_text_buffer() then return end

  local cmd = ascii and ascii_mode or zh_mode
  local ok, _ = pcall(vim.fn.system, cmd)
  if not ok or vim.v.shell_error ~= 0 then vim.notify("Fcitx5 Rime mode switch failed", vim.log.levels.WARN) end
end

-- 判断是否处于注释或字符串中: //,#,",'
local function comment_or_string()
  local node = vim.treesitter.get_node()
  if not node then return false end

  local node_type = node:type()

  -- vim.notify("node_type: " .. node_type, vim.log.levels.DEBUG)
  -- 支持的注释/字符串类型
  local target_type = {
    comment = true,
    line_comment = true,
    block_comment = true,
    string = true,
    string_literal = true,
    string_content = true,
    escape_sequence = true,
    interpolation = true,
    ["#"] = true, -- shell/batch 注释
    comment_content = true,
  }

  return target_type[node_type] ~= nil
end

function M.setup()
  if not is_linux() then return end
  local group = vim.api.nvim_create_augroup("FcitxRimeToggle", { clear = true })

  -- 离开插入模式 切换英文
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    group = group,
    callback = function() set_ascii_mode(true) end,
  })

  -- 进入插入模式，仅在注释或字符串才切中文
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = group,
    callback = function()
      if comment_or_string() then
        set_ascii_mode(false)
      else
        set_ascii_mode(true)
      end
    end,
  })
end

return M
