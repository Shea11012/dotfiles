local add, now_if_args = vim.pack.add, Config.now_if_args
local gh = function(p) return "https://github.com/" .. p end

-- 需要安装的 parser（与 lsp 里启用的语言保持一致）
local parsers = {
  "bash",
  "c",
  "css",
  "diff",
  "dockerfile",
  "go",
  "gomod",
  "gowork",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

now_if_args(function()
  -- main 分支适配 Neovim 0.12+（master 已冻结且不支持 0.12，main 目前也是默认分支）
  add {
    gh "nvim-treesitter/nvim-treesitter",
    gh "nvim-treesitter/nvim-treesitter-textobjects",
  }

  -- 异步安装缺失的 parser（已装的是 no-op）
  require("nvim-treesitter").install(parsers)

  require("nvim-treesitter-textobjects").setup {
    select = {
      -- 和 targets.vim 一样自动向前跳
      lookahead = true,
      selection_modes = {
        ["@function.outer"] = "V",
        ["@class.outer"] = "V",
      },
    },
    move = { set_jumps = true },
  }
end)

-- 内置 ftplugin 只对少量 filetype 调用了 vim.treesitter.start()，
-- 这里对所有有 parser 的 filetype 统一开启高亮
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ConfigTreesitterStart", { clear = true }),
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})
