return {
  handler = "completion_handler",
  opts = {
    -------------------------------------------------
    ---                 deepseek
    -------------------------------------------------
    -- url = "https://api.deepseek.com/beta/completions",
    -- model = "deepseek-chat",
    -- api_type = "deepseek",
    -- fetch_key = vim.env.DEEPSEEK_TOKEN,

    -------------------------------------------------
    ---                 siliconflow
    -------------------------------------------------
    url = "https://api.siliconflow.cn/v1/completions",
    model = "Qwen/Qwen2.5-Coder-7B-Instruct",
    api_type = "openai",
    fetch_key = vim.env.SILICONFLOW_TOKEN,

    n_completions = 2,
    context_window = 16000,
    max_tokens = 4096,
    keep_alive = -1,
    filetypes = {
      sh = false,
      zsh = false,
      llm = false,
    },
    timeout = 10,
    default_filetype_enabled = true,
    auto_trigger = true,
    only_trigger_by_keywords = true,
    style = "blink.cmp",
    -- style = "nvim-cmp",
    -- style = "virtual_text",

    keymap = {
      toggle = {
        mode = "n",
        keys = "<leader>cp",
      },
      virtual_text = {
        accept = {
          mode = "i",
          keys = "<A-a>",
        },
        next = {
          mode = "i",
          keys = "<A-n>",
        },
        prev = {
          mode = "i",
          keys = "<A-p>",
        },
      },
    },
  },
}
