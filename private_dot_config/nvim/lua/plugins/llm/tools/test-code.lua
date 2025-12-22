local prompts = require "plugins.llm.prompts"
return {
  handler = "side_by_side_handler",
  prompt = prompts.TestCode,
  opts = {
    right = {
      border = {
        style = "rounded",
        text = { top = " Test Cases ", top_align = "center" },
      },
    },
  },
}
