local prompts = require "plugins.llm.prompts"
return {
  handler = "flexi_handler",
  prompt = prompts.CodeExplain,
  opts = {
    fetch_key = vim.env.QWEN_KEY,
    url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
    model = "qwen3-coder-plus",
    api_type = "openai",
    enter_flexible_window = true,
    enable_buffer_context = true,
  },
}
