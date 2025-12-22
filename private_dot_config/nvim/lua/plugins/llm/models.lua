return {
  SiliconFlow = {
    name = "SiliconFlow",
    url = "https://api.siliconflow.cn/v1/chat/completions",
    api_type = "openai",
    -- model = "Pro/moonshotai/Kimi-K2-Thinking"
    model = "Qwen/Qwen3-8B", -- think, 免费用于测试
    fetch_key = vim.env.SILICONFLOW_KEY,
    temperature = 0.3,
    top_p = 0.7,
    enable_thinking = true,
  },

  DeepSeek = {
    name = "DeepSeek",
    url = "https://api.deepseek.com/chat/completions",
    api_type = "openai",
    model = "deepseek-chat", -- think: deepseek-reasoner
    fetch_key = vim.env.DEEPSEEK_KEY,
    temperature = 0.3,
    top_p = 0.7,
    enable_thinking = false,
  },

  Qwen = {
    name = "Qwen-coder",
    url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
    api_type = "openai",
    model = "qwen3-coder-plus", -- think
    fetch_key = vim.env.QWEN_KEY,
    temperature = 0.3,
    top_p = 0.7,
    enable_thinking = true,
  },
}
