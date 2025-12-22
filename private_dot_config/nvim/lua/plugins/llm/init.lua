local models = require "plugins.llm.models"
local app_handler = require "plugins.llm.tools"
return {
  "Kurama622/llm.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
  config = function()
    local tools = require "llm.tools"
    require("llm").setup {
      prompt = "你是一个专业的程序员",
      models = {
        models.DeepSeek,
        models.Qwen,
        models.SiliconFlow,
      },
      temperature = 0.3,
      top_p = 0.7,
      app_handler = app_handler,
      lsp = {
        python = { methods = { "definition" } },
        lua = { methods = { "definition", "declaration" } },
        go = { methods = { "definition", "implementation" } },
        typescript = { methods = { "definition", "typeDefinition", "declaration" } },
        javascript = { methods = { "definition" } },
      },
      spinner = {
        text = {
          "󰧞󰧞",
          "󰧞󰧞",
          "󰧞󰧞",
          "󰧞󰧞",
        },
        hl = "Title",
      },

      prefix = {
        -- 
        user = { text = "😃 ", hl = "Title" },
        assistant = { text = "  ", hl = "Added" },
      },
      display = {
        diff = {
          layout = "vertical", -- vertical|horizontal split for default provider
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "mini_diff", -- default|mini_diff
        },
      },
      save_session = true,
      max_history = 15,
      max_history_name_length = 20,
      popwin_opts = {
        relative = "cursor",
        enter = true,
        focusable = true,
        zindex = 50,
        position = { row = -7, col = 15 },
        size = { height = 15, width = "50%" },
        border = { style = "single", text = { top = " Explain ", top_align = "center" } },
        win_options = {
          winblend = 0,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      },
    }
  end,
  keys = {
    { mode = "n", "<leader>ac", "<cmd>LLMSessionToggle<cr>", desc = "toggle LLM chat" },
    { mode = "x", "<leader>at", "<cmd>LLMAppHandler TestCode<cr>", desc = "generate test case" },
    { mode = "n", "<leader>am", "<cmd>LLMAppHandler CommitMsg<cr>", desc = "generate AI commit msg" },
    { mode = { "v", "n" }, "<leader>ae", "<cmd>LLMAppHandler CodeExplain<cr>", desc = "explain code" },
    { mode = { "v", "n" }, "<leader>ak", "<cmd>LLMAppHandler Ask<cr>", desc = "Ask LLM" },
    { mode = { "v", "n" }, "<leader>aa", "<cmd>LLMAppHandler AttachToChat<cr>", desc = "attach to chat" },
    { mode = { "x", "n" }, "<leader>ao", "<cmd>LLMAppHandler OptimizeCode<cr>", desc = "optimize code" },
  },
}
