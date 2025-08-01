local wezterm = require("wezterm")

local act = wezterm.action

local default_prog = {}

local launch_menu = {}

local xim_im_name = ""

-- windows

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	default_prog = { "nu" }

	--   default_prog = { 'nu' }

	table.insert(launch_menu, { label = "pwsh", args = { "pwsh", "-NoLogo" } })

	table.insert(launch_menu, { label = "git bash", args = { "C:/Program Files/Git/bin/bash.exe", "--login" } })

	table.insert(launch_menu, { label = "nushell", args = { "nu" } })
end

-- linux

if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	default_prog = { "fish" }

	xim_im_name = "fcitx5"
end

-- startup

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})

	window:gui_window():maximize()
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- local index = ""

	-- if #tabs > 1 then
	-- 	index = string.format("%d: ", tab.tab_index + 1)
	-- end

	return { {
		Text = " " .. tab.tab_index + 1 .. " ",
	} }
end)

local leader_key = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
local keys = {

	{ key = "F2",         mods = "NONE",  action = act.ActivateCommandPalette },
	{ key = "F3",         mods = "NONE",  action = act.ShowLauncher },

	-- { key = 'UpArrow',    mods = 'ALT',    action = act { ActivatePaneDirection = 'Up' } },
	-- { key = 'DownArrow',  mods = 'ALT',    action = act { ActivatePaneDirection = 'Down' } },

	-- tab
	-- { key = "-", mods = "CTRL", action = act({ CloseCurrentTab = { confirm = false } }) },
	{ key = "LeftArrow",  mods = "SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT", action = act.ActivateTabRelative(1) },

	-- pane
	-- { key = "RightArrow", mods = "ALT", action = act({ ActivatePaneDirection = "Prev" }) },
	-- { key = "LeftArrow", mods = "ALT", action = act({ ActivatePaneDirection = "Next" }) },
	-- { key = "w", mods = "CTRL", action = act({ CloseCurrentPane = { confirm = false } }) },
	-- { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- rename tab
	-- {
	-- 	key = "R",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = act.PromptInputLine({
	-- 		description = "Enter new name for tab",
	-- 		action = wezterm.action_callback(function(window, pane, line)
	-- 			if line then
	-- 				window:active_tab():set_title(line)
	-- 			end
	-- 		end),
	-- 	}),
	-- },
}

local config = {

	-- basic
	enable_scroll_bar = true,

	launch_menu = launch_menu,

	color_scheme = "Tokyo Night",

	default_prog = default_prog,

	use_ime = true,

	xim_im_name = xim_im_name,

	--   ime_preedit_rendering = "System",

	audible_bell = "Disabled",

	window_close_confirmation = "NeverPrompt",

	-- window

	adjust_window_size_when_changing_font_size = true,

	window_background_opacity = 0.9,
	text_background_opacity = 0.3,

	window_padding = { left = 5, right = 5, top = 5, bottom = 5 },

	inactive_pane_hsb = { hue = 1.0, saturation = 1.0, brightness = 1.0 },

	-- font

	font = wezterm.font_with_fallback({ "Maple Mono NF CN", "LXGW WenKai GB Screen" }),

	font_size = 18,

	-- freetype_load_target = "Mono",

	-- warn_about_missing_glyphs = false,

	-- Tab bar

	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,

	tab_max_width = 25,

	-- keys
	leader = leader_key,
	disable_default_key_bindings = false,

	use_dead_keys = false,

	keys = keys,
}

return config
