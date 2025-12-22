return {
  handler = "action_handler",
  opts = {
    fetch_key = vim.env.QWEN_KEY,
    url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
    model = "qwen-plus",
    api_type = "openai",
    language = "Chinese",
    diagnostic = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  },
}
