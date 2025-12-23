local ad = require "codecompanion.adapters"
return {
  http = {
    opts = {
      show_presets = false,
    },
    deepseek = function()
      return ad.extend("deepseek", {
        env = {
          api_key = vim.env.DEEPSEEK_KEY,
        },
      })
    end,
    qwen = function()
      return ad.extend("openai_compatible", {
        name = "qwen",
        env = {
          api_key = vim.env.QWEN_KEY,
          url = "https://dashscope.aliyuncs.com/compatible-mode",
          chat_url = "/v1/chat/completions",
        },
        schema = {
          model = {
            default = "qwen3-coder-plus",
            choices = {
              ["qwen-plus"] = {
                formatted_name = "qwen plus",
                opts = { can_reson = true, can_use_tools = true },
              },
              ["qwen3-coder-plus"] = {
                formatted_name = "qwen3 coder plus",
                opts = { can_use_tools = true },
              },
              ["qwen-flash"] = {
                formatted_name = "qwen flash",
                opts = { can_reson = true, can_use_tools = true },
              },
            },
          },
        },
      })
    end,
  },
}
