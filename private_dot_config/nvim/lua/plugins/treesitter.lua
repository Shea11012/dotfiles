local ensure_installed = {
  "bash",
  "c",
  "css",
  "diff",
  "gitcommit",
  "html",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "query",
  "vimdoc",
  "vim",
  "json",
  "yaml",
  "rust",
  "go",
  "javascript",
  "http",
}

local ts = require "nvim-treesitter"
local available_set = {}
vim.tbl_map(function(v) available_set[v] = true end, ts.get_available())

local installed = ts.get_installed()
local installed_set = {}
for _, name in ipairs(installed) do
  installed_set[name] = true
end

local function treesitter_init(bufnr)
  -- 确保缓冲区加载
  if not vim.api.nvim_buf_is_loaded(bufnr) then return end

  -- 避免重复初始化
  if vim.b[bufnr].treesitter_initialized then return end

  -- 大多数ui插件都是只可读和不可写
  if vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then return end

  local ft = vim.bo[bufnr].filetype
  if not available_set[ft] then
    -- vim.notify("treesitter not available " .. ft, vim.log.levels.DEBUG)
    return
  end

  if not installed_set[ft] then
    -- 如果可用，则下载，限时5分钟
    ts.install(ft):wait(300000)
    installed_set[ft] = true
  end

  -- syntax highlighting, provided by Neovim
  vim.treesitter.start()
  -- folds, provided by Neovim
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.wo.foldmethod = "expr"
  -- indentation, provided by nvim-treesitter
  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

  vim.b[bufnr].treesitter_initialized = true
end

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    version = false,
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ["@function.outer"] = "V",

            ["@class.outer"] = "V",
            ["@parameter.inner"] = "v",
          },
          include_surrounding_whitespace = true,
        },
        move = {
          set_jumps = false,
        },
      }

      local keymaps = {
        { "af", "@function.outer", "arround function" },
        { "ab", "@block.outer", "arround block" },
      }

      local mode = { "n", "x", "o" }
      for _, key in pairs(keymaps) do
        vim.keymap.set(
          mode,
          key[1],
          function() require("nvim-treesitter-textobjects.select").select_textobject(key[2], "textobjects") end,
          { desc = key[3] }
        )
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    main = nil,
    event = "BufReadPre",
    build = function()
      if vim.fn.exists ":TSUpdate" == 2 then vim.cmd "TSUpdate" end
    end,
    version = false,
    config = function()
      -- 在BufWinEnter加载 treesitter 更合理，方便其它插件的ui加载完成
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function(ev)
          -- 延迟10ms,确保ui加载完成
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_loaded(ev.buf) then treesitter_init(ev.buf) end
          end, 10)
        end,
      })
      ts.install(ensure_installed)
    end,
  },
}
