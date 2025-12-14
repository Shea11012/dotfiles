if not vim.g.neovide then return {} end

vim.g.transparency = 0.9
local alpha = function() return string.format("%x", math.floor(255 * vim.g.transparency or 0.8)) end

local neovide_background_color = "#000000" .. alpha()
return {
  "AstroNvim/astrocore",
  opts = {
    options = {
      opt = {
        guifont = "Maple Mono Font CN,LXGW WenKai Screen:h16",
        linespace = 0,
      },
      g = {
        -- 控制鼠标动画
        neovide_cursor_short_animation_length = 0,
        neovide_position_animation_length = 0,
        neovide_cursor_animation_length = 0.00,
        neovide_cursor_trail_size = 0,
        neovide_cursor_animate_in_insert_mode = false,
        neovide_cursor_animate_command_line = false,
        neovide_scroll_animation_far_lines = 0,
        neovide_scroll_animation_length = 0.00,
        -- 控制透明度
        neovide_opacity = 0.9,
        neovide_background_color = neovide_background_color,
      },
    },
  },
}
