local M = {}

-- fcitx5-rime 的 D-Bus 接口: SetAsciiMode(b)
-- 也可用 IsAsciiMode 查询，但查询同样要 fork 一次 busctl，故不采用
local BUSCTL = { "busctl", "call", "--user", "org.fcitx.Fcitx5", "/rime", "org.fcitx.Fcitx.Rime1", "SetAsciiMode", "b" }

local NON_TEXT_FILETYPES = {
  git = true,
  gitcommit = true,
  gitrebase = true,
  diff = true,
  help = true,
  qf = true,
  man = true,
  dashboard = true,
  alpha = true,
  packer = true,
  lazy = true,
  mason = true,
  telescope = true,
  oil = true,
  fugitive = true,
  nvimtree = true,
  snacks_picker_input = true,
}

-- 注释/字符串节点：祖先链上任意一层命中即算
local COMMENT_OR_STRING = {
  comment = true,
  line_comment = true,
  block_comment = true,
  comment_content = true,
  string = true,
  string_literal = true,
  string_content = true,
  char_literal = true,
  escape_sequence = true,
  interpolation = true,
  ["#"] = true, -- shell/batch 注释
}

local is_linux = (function()
  if jit then return jit.os == "Linux" end
  local uv = vim.uv or vim.loop
  return uv ~= nil and uv.os_uname().sysname == "Linux"
end)()

-- nil = 未知/上次失败(下次必定发送), true = 英文, false = 中文
-- 语义是「我们最后一次命令的模式」，用于跳过冗余调用
local ascii_state = nil

local function build_cmd(flag)
  local cmd = {}
  for i = 1, #BUSCTL do
    cmd[i] = BUSCTL[i]
  end
  cmd[#cmd + 1] = flag
  return cmd
end

local ASCII_CMD = build_cmd "true"
local ZH_CMD = build_cmd "false"

local function is_normal_text_buffer(buf)
  local bo = vim.bo[buf or 0]
  if bo.buftype ~= "" and bo.buftype ~= "acwrite" then return false end
  if NON_TEXT_FILETYPES[bo.filetype] then return false end
  return bo.buflisted
end

local function do_set_ascii_mode(ascii)
  local cmd = ascii and ASCII_CMD or ZH_CMD

  if not vim.system then -- nvim < 0.10 兜底
    local ok = pcall(vim.fn.system, cmd)
    if not ok or vim.v.shell_error ~= 0 then
      ascii_state = nil
      vim.notify("Fcitx5 Rime mode switch failed", vim.log.levels.WARN)
    end
    return
  end

  -- 异步：不阻塞 InsertEnter/InsertLeave，失败时回滚状态以便下次重试
  local ok = pcall(vim.system, cmd, { text = true }, function(res)
    if res.code ~= 0 then
      ascii_state = nil
      local err = vim.trim(res.stderr or "")
      vim.schedule(function() vim.notify("Fcitx5 Rime mode switch failed: " .. err, vim.log.levels.WARN) end)
    end
  end)
  if not ok then ascii_state = nil end
end

---@param ascii boolean true=英文模式 false=中文模式
---@param force boolean 忽略去重，强制发送（用于 InsertLeave 纠正手动切换）
local function set_ascii_mode(ascii, force)
  if not is_normal_text_buffer() then return end -- 不记录状态，换到正常 buffer 后会重试
  if not force and ascii_state == ascii then return end
  ascii_state = ascii
  do_set_ascii_mode(ascii)
end

-- 无 parser 时的兜底：行首 # // -- * 视为注释
local function line_looks_like_comment()
  local before = vim.api.nvim_get_current_line():sub(1, vim.api.nvim_win_get_cursor(0)[2])
  return before:match "^%s*#" ~= nil
    or before:match "^%s*//" ~= nil
    or before:match "^%s*%-%-" ~= nil
    or before:match "^%s*%*" ~= nil
end

local function comment_or_string()
  local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = false })
  if not ok or not node then return line_looks_like_comment() end

  while node do
    if COMMENT_OR_STRING[node:type()] then return true end
    node = node:parent()
  end
  return false
end

---@class IMSwitchOpts
---@field enabled? boolean            总开关
---@field ascii_on_leave? boolean     离开插入模式是否切回英文
---@field zh_in_comment? boolean      光标在注释/字符串内时是否切中文
---@field dedupe? boolean             进入插入模式时跳过与上次相同的模式设置
---@field extra_exclude? string[]     额外排除的 filetype

---@param opts? IMSwitchOpts
function M.setup(opts)
  opts = vim.tbl_extend("force", {
    enabled = true,
    ascii_on_leave = true,
    zh_in_comment = true,
    dedupe = true,
    extra_exclude = {},
  }, opts or {})

  if not is_linux or not opts.enabled then return end
  for _, ft in ipairs(opts.extra_exclude) do
    NON_TEXT_FILETYPES[ft] = true
  end

  local group = vim.api.nvim_create_augroup("FcitxRimeToggle", { clear = true })

  -- 离开插入模式：强制切英文。
  -- 这里不用去重，因为你可能在插入模式里手动 Ctrl+Space 切过中文，
  -- 只有强制下发才能保证回到普通模式后是英文（异步调用不阻塞 UI）
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      if opts.ascii_on_leave then set_ascii_mode(true, true) end
    end,
  })

  -- 进入插入模式：仅在注释或字符串里切中文，否则英文
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if opts.zh_in_comment and comment_or_string() then
        set_ascii_mode(false, not opts.dedupe)
      else
        set_ascii_mode(true, not opts.dedupe)
      end
    end,
  })
end

return M
