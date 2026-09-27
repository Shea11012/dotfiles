local mp = require "mp"
local utils = require "mp.utils"

local RECORD_FILENAME = ".mpv-record.json"
local RESUME_BACK_SECONDS = 10
local COMPLETED_PERCENT = 95

local video_extensions = {
    mp4 = true,
    mkv = true,
    avi = true,
    mov = true,
    wmv = true,
    flv = true,
    webm = true,
    m4v = true,
    mpg = true,
    mpeg = true,
    ts = true,
    m2ts = true,
    vob = true,
    ogv = true,
}

local state = {
    path = nil,
    dir = nil,
    filename = nil,
    is_video = false,
    had_record = false,
    last_time_pos = nil,
    percent_pos = nil,
}

local function reset_state()
    state.path = nil
    state.dir = nil
    state.filename = nil
    state.is_video = false
    state.had_record = false
    state.last_time_pos = nil
    state.percent_pos = nil
end

local function split_path(path)
    if not path then
        return nil, nil
    end
    local dir, filename = utils.split_path(path)
    if not dir or not filename or filename == "" then
        return nil, nil
    end
    return dir, filename
end

local function record_path(dir)
    return utils.join_path(dir, RECORD_FILENAME)
end

local function empty_data()
    return { version = 1, records = {} }
end

local function file_exists(path)
    return utils.file_info(path) ~= nil
end

local function read_file(path)
    local file, open_error = io.open(path, "rb")
    if not file then
        return nil, open_error
    end

    local content = file:read("*a")
    local close_ok, close_error = file:close()
    if content == nil then
        return nil, "无法读取文件内容"
    end
    if close_ok == nil then
        return nil, close_error
    end
    return content
end

local function write_file(path, content)
    local file, open_error = io.open(path, "wb")
    if not file then
        return false, open_error
    end

    local ok, write_error = file:write(content)
    local close_ok, close_error = file:close()
    if not ok then
        return false, write_error
    end
    if close_ok == nil then
        return false, close_error
    end
    return true
end

local function write_data(dir, data, show_error)
    local json = utils.format_json(data)
    if not json then
        mp.msg.error("无法编码进度记录")
        if show_error then
            mp.osd_message("进度记录编码失败", 3)
        end
        return false
    end

    local ok, err = write_file(record_path(dir), json)
    if not ok then
        mp.msg.error("无法写入进度记录 " .. record_path(dir) .. ": " .. tostring(err))
        if show_error then
            mp.osd_message("当前目录不可写，进度未保存", 3)
        end
        return false
    end
    return true
end

local function recover_corrupt_data(dir, content)
    local source = record_path(dir)
    local backup = source .. ".corrupt." .. tostring(os.time())
    local ok, err = write_file(backup, content)
    if ok then
        mp.msg.warn("进度文件已损坏，备份到 " .. backup)
    else
        mp.msg.error("无法备份损坏的进度文件 " .. source .. ": " .. tostring(err))
    end

    local data = empty_data()
    write_data(dir, data, true)
    return data
end

local function read_data(dir, recover)
    local path = record_path(dir)
    if not file_exists(path) then
        return empty_data()
    end

    local content, read_error = read_file(path)
    if not content then
        mp.msg.error("无法读取进度记录 " .. path .. ": " .. tostring(read_error))
        return empty_data()
    end

    local data, parse_error = utils.parse_json(content)
    if type(data) ~= "table" or type(data.records) ~= "table" then
        mp.msg.error("无法解析进度记录 " .. path .. ": " .. tostring(parse_error or "结构无效"))
        if recover then
            return recover_corrupt_data(dir, content)
        end
        return empty_data()
    end
    return data
end

local function is_video_file(filename)
    if not filename then
        return false
    end
    local extension = filename:match("%.([^./\\]+)$")
    return extension ~= nil and video_extensions[extension:lower()] == true
end

local function list_video_files(dir)
    local files = utils.readdir(dir, "files")
    if not files then
        mp.msg.warn("无法扫描目录 " .. dir)
        return nil
    end

    local videos = {}
    for _, filename in ipairs(files) do
        if is_video_file(filename) then
            videos[#videos + 1] = filename
        end
    end
    return videos
end

local function prune_missing_records(dir, data)
    local files = list_video_files(dir)
    if not files then
        return false
    end

    local present = {}
    for _, filename in ipairs(files) do
        present[filename] = true
    end

    local changed = false
    for filename in pairs(data.records) do
        if not present[filename] or not is_video_file(filename) then
            data.records[filename] = nil
            changed = true
        end
    end
    return changed
end

local function is_directory_completed(dir, data)
    local files = list_video_files(dir)
    if not files or #files == 0 then
        return false
    end

    for _, filename in ipairs(files) do
        local record = data.records[filename]
        if type(record) ~= "table"
            or type(record.percent) ~= "number"
            or record.percent < COMPLETED_PERCENT then
            return false
        end
    end
    return true
end

local function has_playable_video()
    local tracks = mp.get_property_native("track-list", {})
    for _, track in ipairs(tracks) do
        if track.type == "video" and not track.image then
            return true
        end
    end
    return false
end

local function save_current_record(show_error)
    if not state.path or not state.dir or not state.filename or not state.is_video then
        return false
    end
    if type(state.last_time_pos) ~= "number" or type(state.percent_pos) ~= "number" then
        return false
    end

    -- 保存前重读并只合并当前视频，降低多个 mpv 实例互相覆盖的概率。
    -- 这不是文件锁；两个实例恰好同时写入时仍可能冲突。
    local data = read_data(state.dir, true)
    data.records[state.filename] = {
        time = math.max(0, state.last_time_pos - RESUME_BACK_SECONDS),
        percent = state.percent_pos,
        updated_at = os.time(),
    }
    prune_missing_records(state.dir, data)

    if not write_data(state.dir, data, show_error) then
        return false
    end
    state.had_record = true
    return true
end

local function on_file_loaded()
    reset_state()

    local path = mp.get_property_native("path")
    local dir, filename = split_path(path)
    if not path or not dir or dir == "." then
        return
    end

    state.path = path
    state.dir = dir
    state.filename = filename
    state.is_video = has_playable_video()
    if not state.is_video then
        return
    end

    local data = read_data(dir, true)
    if prune_missing_records(dir, data) then
        write_data(dir, data, false)
    end

    local record = data.records[filename]
    state.had_record = type(record) == "table"
    if state.had_record
        and type(record.time) == "number"
        and record.time > 0
        and type(record.percent) == "number"
        and record.percent < COMPLETED_PERCENT then
        mp.commandv("seek", record.time, "absolute", "exact")
    end
end

local function create_menu_data()
    local menu = {
        type = "records",
        title = "记录列表",
        callback = { mp.get_script_name(), "record-event" },
        items = {},
    }
    if not state.dir then
        return menu
    end

    local data = read_data(state.dir, true)
    if prune_missing_records(state.dir, data) then
        write_data(state.dir, data, false)
    end

    if is_directory_completed(state.dir, data) then
        menu.items[#menu.items + 1] = {
            title = "✓ 目录已完成",
            value = "__completed__",
            icon = "check_circle",
        }
    end

    local filenames = {}
    for filename in pairs(data.records) do
        filenames[#filenames + 1] = filename
    end
    table.sort(filenames, function(a, b)
        local record_a, record_b = data.records[a], data.records[b]
        local time_a = type(record_a) == "table" and tonumber(record_a.updated_at) or 0
        local time_b = type(record_b) == "table" and tonumber(record_b.updated_at) or 0
        time_a, time_b = time_a or 0, time_b or 0
        if time_a ~= time_b then
            return time_a > time_b
        end
        return a < b
    end)

    for _, filename in ipairs(filenames) do
        local record = data.records[filename]
        local percent = type(record.percent) == "number" and record.percent or 0
        menu.items[#menu.items + 1] = {
            title = filename .. "  " .. tostring(percent) .. "%",
            value = filename,
        }
    end
    return menu
end

local function list_records()
    local menu = create_menu_data()
    if #menu.items == 0 then
        mp.osd_message("无记录", 3)
        return
    end
    mp.commandv("script-message-to", "uosc", "open-menu", utils.format_json(menu))
end

mp.register_script_message("record-event", function(value)
    local event = utils.parse_json(value)
    if type(event) ~= "table" then
        mp.msg.warn("无法解析记录菜单事件")
        return
    end
    if event.type ~= "activate" or event.action ~= nil or event.value == "__completed__" then
        return
    end

    local playlist = mp.get_property_native("playlist", {})
    for index, item in ipairs(playlist) do
        local _, filename = split_path(item.filename)
        if filename == event.value then
            mp.commandv("playlist-play-index", index - 1)
            return
        end
    end
end)

mp.observe_property("time-pos", "native", function(_, value)
    if not state.path or type(value) ~= "number" then
        return
    end
    state.last_time_pos = value
end)

mp.observe_property("percent-pos", "native", function(_, value)
    if not state.path or type(value) ~= "number" then
        return
    end
    local rounded = math.floor(value + 0.5)
    state.percent_pos = rounded
end)

mp.register_event("file-loaded", on_file_loaded)

mp.register_event("end-file", function()
    save_current_record(true)
    reset_state()
end)

mp.register_event("shutdown", function()
    save_current_record(true)
end)

mp.add_key_binding(nil, "records-list", list_records)

mp.register_script_message("cleanup-records", function()
    if not state.dir then
        mp.osd_message("当前没有可清理的媒体目录", 2)
        return
    end

    local data = read_data(state.dir, true)
    local changed = prune_missing_records(state.dir, data)
    if changed then
        write_data(state.dir, data, true)
    end
    mp.osd_message(changed and "已清理失效记录" or "没有失效记录", 2)
end)
