local prompts = require "plugins.llm.prompts"
return {
  handler = "flexi_handler",
  prompt = prompts.CommitMsg,

  opts = {
    fetch_key = vim.env.SILICONFLOW_KEY,
    url = "https://api.siliconflow.cn/v1/chat/completions",
    model = "deepseek-ai/DeepSeek-V3.2",
    api_type = "openai",
    enter_flexible_window = true,
    apply_visual_selection = false,
    win_opts = {
      relative = "editor",
      position = "50%",
      zindex = 70,
    },
    accept = {
      mapping = {
        mode = "n",
        keys = "<cr>",
      },
      action = function()
        local contents = vim.api.nvim_buf_get_lines(0, 0, -1, true)

        local cmd = string.format('!git commit -m "%s"', table.concat(contents, '" -m "'))
        cmd = (cmd:gsub(".", {
          ["#"] = "\\#",
        }))
        vim.api.nvim_command(cmd)

        -- just for lazygit
        vim.schedule(function() vim.api.nvim_command "LazyGit" end)
      end,
    },
  },
}
