return {
  "olimorris/codecompanion.nvim",
  version = "^18.0.0",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local adapters = require "plugins.codecompanion.adapters"
    require("codecompanion").setup {
      adapters = adapters,
      interactions = {
        chat = {
          adapter = "qwen",
        },
        inline = {
          adapter = { name = "qwen", model = "qwen3-coder-plus" },
        },
        background = {
          adapter = { name = "qwen", model = "qwen-plus" },
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            vim.fn.stdpath "config" .. "/lua/plugins/codecompanion/prompts",
          },
        },
      },
      opts = {
        language = "chinese",
      },
    }
  end,
  keys = {
    { mode = { "n", "x", "v" }, "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "codecompanion chat" },
    { mode = { "x" }, "<leader>ai", ":CodeCompanion<cr>", desc = "codecompanion inline" },
    {
      mode = { "n", "x", "v" },
      "<leader>aa",
      "<cmd>CodeCompanionActions<cr>",
      desc = "codecompanion actions",
    },
  },

  event = { "CmdlineEnter" },
}
