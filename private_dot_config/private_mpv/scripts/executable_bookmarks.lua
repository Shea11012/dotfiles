-- bookmarks.lua - bookmarks as chapters for uosc, with persistence, delete, list
local mp = require("mp")
local utils = require("mp.utils")

local orig_chapters = {}
local marks = {} -- { {time=.., title="★ 00:00:00.00"} , ... } sorted by time
local delete_threshold = 0.75 -- seconds to consider "nearby" for deletion
local list_duration = 3 -- OSD seconds

local function timefmt(t)
	local h = math.floor(t / 3600)
	local m = math.floor(t % 3600 / 60)
	local s = t % 60
	return string.format("%02d:%02d:%05.2f", h, m, s)
end

local function sanitize(name)
	return (name or ""):gsub('[\\/:%*%?"<>|]', "_"):gsub("%s+$", "")
end

local function is_url(path)
	return type(path) == "string" and path:match("^[%a][%w%+%-%.]*://") ~= nil
end

local function ensure_dir(path)
	local info = utils.file_info(path)
	if info and info.is_dir then
		return true
	end
	local sep = package.config:sub(1, 1)
	if sep == "\\" then
		mp.command_native({ name = "subprocess", playback_only = false, args = { "cmd", "/C", "mkdir", path } })
	else
		mp.command_native({ name = "subprocess", playback_only = false, args = { "mkdir", "-p", path } })
	end
	local info2 = utils.file_info(path)
	return info2 and info2.is_dir
end

local function persist_path()
	local path = mp.get_property_native("path")
	if not path then
		return nil
	end
	if is_url(path) then
		-- URL/流：落在配置目录下
		local base = utils.get_user_path("~~/")
		local dir = utils.join_path(base, "script-opts")
		dir = utils.join_path(dir, "bookmarks")
		if not ensure_dir(dir) then
			return nil
		end
		local key = sanitize(path)
		return utils.join_path(dir, key .. ".bookmarks.json")
	else
		-- 本地文件：侧车 JSON
		local dir, file = utils.split_path(path)
		return utils.join_path(dir, file .. ".bookmarks.json")
	end
end

local function rebuild_chapters()
	local merged = {}
	for i = 1, #orig_chapters do
		merged[i] = { time = orig_chapters[i].time, title = orig_chapters[i].title }
	end
	for _, m in ipairs(marks) do
		table.insert(merged, m)
	end
	table.sort(merged, function(a, b)
		return a.time < b.time
	end)
	mp.set_property_native("chapter-list", merged)
end

local function save_marks()
	local out = {}
	for _, m in ipairs(marks) do
		out[#out + 1] = { time = m.time, title = m.title }
	end
	local p = persist_path()
	if not p then
		return
	end
	local fh = io.open(p, "wb")
	if not fh then
		return
	end
	fh:write(utils.format_json(out))
	fh:close()
end

local function load_marks()
	marks = {}
	local p = persist_path()
	if not p then
		return
	end
	local fh = io.open(p, "rb")
	if not fh then
		return
	end
	local data = fh:read("*a")
	fh:close()
	if not data or #data == 0 then
		return
	end
	local arr = utils.parse_json(data) or {}
	for _, m in ipairs(arr) do
		if type(m.time) == "number" then
			table.insert(marks, { time = m.time, title = m.title or ("★ " .. timefmt(m.time)) })
		end
	end
	table.sort(marks, function(a, b)
		return a.time < b.time
	end)
end

local function add_mark()
	local pos = mp.get_property_native("time-pos")
	if not pos then
		return
	end
	for _, m in ipairs(marks) do
		if math.abs(m.time - pos) < 0.3 then
			mp.osd_message("已存在相近书签 " .. timefmt(m.time))
			return
		end
	end
	local m = { time = pos, title = "★ " .. timefmt(pos) }
	table.insert(marks, m)
	table.sort(marks, function(a, b)
		return a.time < b.time
	end)
	rebuild_chapters()
	save_marks()
	mp.osd_message("添加书签 " .. timefmt(pos))
end

local function del_nearby_mark()
	local pos = mp.get_property_native("time-pos")
	if not pos or #marks == 0 then
		mp.osd_message("无可删书签")
		return
	end
	local best_i, best_d = nil, nil
	for i, m in ipairs(marks) do
		local d = math.abs(m.time - pos)
		if not best_d or d < best_d then
			best_d, best_i = d, i
		end
	end
	if best_d and best_d <= delete_threshold then
		local t = marks[best_i].time
		table.remove(marks, best_i)
		rebuild_chapters()
		save_marks()
		mp.osd_message("删除书签 " .. timefmt(t))
	else
		mp.osd_message("附近没有书签(阈值 ±" .. tostring(delete_threshold) .. "s)")
	end
end

local function next_mark(dir)
	local pos = mp.get_property_native("time-pos") or 0
	if #marks == 0 then
		mp.osd_message("无书签")
		return
	end
	local best = nil
	for i, m in ipairs(marks) do
		local delta = (m.time - pos) * dir
		if delta > 1e-6 and (not best or delta < best.delta) then
			best = { delta = delta, i = i }
		end
	end
	if not best then
		best = { i = (dir > 0) and 1 or #marks }
	end
	local t = marks[best.i].time
	mp.commandv("seek", tostring(t), "absolute", "exact")
	mp.osd_message(((dir > 0) and "下一个书签 " or "上一个书签 ") .. timefmt(t))
end

local function prev_mark()
	next_mark(-1)
end
local function goto_next()
	next_mark(1)
end

local function create_menu_data()
	local menu_data = {
		type = "bookmarks",
		title = "书签列表",
		callback = { mp.get_script_name(), "bookmark-event" },
		items = {},
	}

	local items = {}

	for i, mark in ipairs(marks) do
		local display_title = string.format("%d. %s", i, mark.title)
		table.insert(items, {
			title = display_title,
			value = { time = mark.time, index = i },
			-- 右侧添加删除按钮
			actions = {
				{
					name = "delete",
					icon = "delete",
					label = "delete",
				},
			},
		})
	end
	menu_data.items = items

	return menu_data
end

local function list_marks()
	if #marks == 0 then
		mp.osd_message("无书签", list_duration)
		return
	end
	local menu_data = create_menu_data()
	mp.commandv("script-message-to", "uosc", "open-menu", utils.format_json(menu_data))
end

mp.register_script_message("bookmark-event", function(json)
	local event = utils.parse_json(json)
	if event.type == "activate" then
		-- action == nil 表示是enter 跳转到指定的time
		if event.action == nil then
			mp.commandv("seek", tostring(event.value.time), "absolute", "exact")
			mp.osd_message("跳转到书签", 1000)
		end

		-- 删除
		if event.action == "delete" then
			table.remove(marks, event.value.index)
			rebuild_chapters()
			save_marks()
			-- 刷新菜单
			local menu_data = create_menu_data()
			mp.commandv("script-message-to", "uosc", "update-menu", utils.format_json(menu_data))
		end
	end
end)

mp.register_event("file-loaded", function()
	orig_chapters = mp.get_property_native("chapter-list") or {}
	load_marks()
	rebuild_chapters()
end)

mp.add_key_binding(nil, "bookmarks-add", add_mark)
mp.add_key_binding(nil, "bookmarks-prev", prev_mark)
mp.add_key_binding(nil, "bookmarks-next", goto_next)
mp.add_key_binding(nil, "bookmarks-del", del_nearby_mark)
mp.add_key_binding(nil, "bookmarks-list", list_marks)
