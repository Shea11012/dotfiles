// biome-ignore lint: mpv js no check
// biome-ignore assist: mpv js no check
(function () {
  /**
   * @typedef {object} Record
   * @property {string} filename
   * @property {string} time
   */

  /**
   *@type {{dir: string, records:Object.<string,Record>}}
   */
  var data = {};
  var filename = "record-playlist.json";
  var path;
  var isImage; // 需要在加载时就判断，否则在end-file和shutdown事件则会变为auto
  var isAudio;

  function abs(num) {
    return num < 0 ? num >>> 0 : num;
  }

  var base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz";
  function base36(num) {
    var result = "";
    if (num == 0) return "0";
    while (num > 0) {
      result = base36Chars[num % 36] + result;
      num = (num / 36) | 0; // 位运算截断小数部分
    }
    return result;
  }

  function hash(str) {
    var hash = 0;
    for (var i = 0; i < str.length; i++) {
      var char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      // 确保hash是一个32位有符号数
      hash = hash | 0;
    }
    return base36(abs(hash));
 
  }
function dirHash(dir) {
    // 1. 统一路径分隔符，处理 Windows 路径
    var normalized = dir.replace(/\\/g, '/');

    // 2. 分割路径并过滤空字符串
    var parts = normalized.split('/').filter(function(v) {
        return v !== "";
    });

    // 3. 去除根目录或盘符 (例如 "C:" 或 "mnt")
    // 如果第一部分包含冒号（Windows盘符），通常去掉它以实现跨盘符通用
    if (parts.length > 0 && parts[0].indexOf(":") !== -1) {
        parts.shift();
    }
    
    // (可选) 如果你在 Linux 下且挂载点层级很深且固定（如 /media/user/），
    // 也可以在这里写逻辑去掉前几层，但通用做法是直接取末尾。

    if (parts.length === 0) {
        // 如果路径为空（例如根目录文件），使用特殊标识
        return { key: hash("root"), dir: "/" };
    }

    // --- 核心配置：相对路径深度 ---
    // 取最后 2 级目录。
    // 例子：/mnt/usb1/Videos/Action/MovieA -> 取 ["Action", "MovieA"]
    // 优点：即使挂载点变成 /media/user/usb，只要目录结构是 Videos/Action/MovieA，Key 就不变。
    var DEPTH = 3; 

    // 计算切片的起始位置
    var start = Math.max(0, parts.length - DEPTH);
    
    // 获取相对路径部分
    var relativeParts = parts.slice(start);
    var relativeDir = relativeParts.join('/');

    // 4. 如果取出来的相对路径太短（比如只有1层），为了减少冲突，可以用完整路径的非根部分
    if (relativeDir.length < 3) {
        relativeDir = parts.join('/');
    }

    return {
        key: hash(relativeDir),
        dir: relativeDir // 存储“看起来”更干净的相对路径
    };
}
  /**
   * @param {Array} array
   * @param {callable} fn
   * @return int
   */
  function findIndex(arr,fn) {
    for(var i=0; i<arr.length;i++) {
      if(fn(arr[i])) return i
    }

    return -1
  }

  function get_filename() {
    var path = mp.utils.get_user_path("~~/");
    var file = mp.utils.join_path(path, filename);
    return file;
  }

  function file_exists(filename) {
    return !!mp.utils.file_info(filename);
  }

  function create_menu_data() {
    var file_info = split_path(path);
    var dirData = get_dirData(file_info.dir);
    var menu_data = {
      type: "records",
      title: "记录列表",
      callback: [mp.get_script_name(), "record-event"]
    };
    var items = [];
    
    if (dirData && dirData.completed) {
      items.push({
        title: "✓ 目录已完成",
        value: "__completed__",
        icon: "check_circle"
      });
    }
    
    if (dirData && dirData.records) {
      for (var i = 0; i < dirData.records.length; i++) {
        var record = dirData.records[i];
        items.push({
          title: record.filename + "  " + record.percent_pos + "%",
          value: record.filename
        });
      }
    }
    
    menu_data.items = items;
    return menu_data;
  }

  function list_records() {
    var menu_data = create_menu_data();
    if (menu_data.items.length === 0) {
      mp.osd_message("无记录", 3000);
      return;
    }
    mp.commandv("script-message-to", "uosc", "open-menu", JSON.stringify(menu_data));
  }

  mp.register_script_message("record-event", function(value) {
    var event = JSON.parse(value);
    if (event.type === "activate" && event.action === undefined) {
      if (event.value === "__completed__") {
        return;
      }
      var playlists = mp.get_property_native("playlist");
      var idx = findIndex(playlists, function(val) {
        var filename = val.filename.substring(2);
        return filename === event.value;
      });
      if (idx !== -1) mp.commandv("playlist-play-index", idx);
    }
  });

  function load_data() {
    try {
      var filename = get_filename();
      if (!file_exists(filename)) {
        data = {};
        return;
      }
      var content = mp.utils.read_file(filename);
      data = JSON.parse(content) || {};
    } catch (e) {
      data = {}
    }
  }

  function save_data() {
    var str = JSON.stringify(data);
    var filename = get_filename();
    mp.utils.write_file("file://" + filename, str);
  }
// 将后缀列表编译为一个正则表达式，忽略大小写
var video_ext_regex = /\.(mp4|mkv|avi|mov|wmv|flv|webm|m4v|mp3|m4a|wav|flac)$/i;

function is_media_file(filename) {
    if (!filename) return false;
    return video_ext_regex.test(filename);
}

  function count_video_files(dir) {
    try {
      var files = mp.utils.readdir(dir, "files");
      if (!files) return 0;
      var count = 0;
      for (var i = 0; i < files.length; i++) {
        if (is_media_file(files[i])) {
          count++;
        }
      }
      return count;
    } catch (e) {
      mp.msg.warn("无法扫描目录 " + dir + ": " + e);
      return 0;
    }
  }

  function check_dir_completed(dirData) {
    if (!dirData || !dirData.records || dirData.records.length === 0) {
      return false;
    }
    
    if (dirData.total_count && dirData.records.length < dirData.total_count) {
      return false;
    }
    
    for (var i = 0; i < dirData.records.length; i++) {
      var record = dirData.records[i];
      if (!record.percent_pos || record.percent_pos < 95) {
        return false;
      }
    }
    return true;
  }

  function cleanup_completed_dirs() {
    var completed_count = 0;
    var now = Date.now();
    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        var dirData = data[key];
        if(dirData.completed) continue;
        if (check_dir_completed(dirData)) {
          dirData.completed = true
          dirData.completed_at = now;
          completed_count++;
        }
      }
    }
    if (completed_count > 0) {
      save_data();
      mp.osd_message("清理了 " + completed_count + " 个已完成目录", 2000);
    }
    return completed_count;
  }

  function cleanup_old_completed(max_days) {
    var maxDays = max_days || 30;
    var threshold = Date.now() - (maxDays * 24 * 60 * 60 * 1000);
    var count = 0;
    var key;
    
    for (key in data) {
      if (data.hasOwnProperty(key)) {
        var dirData = data[key];
        if (dirData.completed && dirData.completed_at < threshold) {
          delete data[key];
          count++;
        }
      }
    }
    
    if (count > 0) {
      save_data();
    }
    return count;
  }

  /**
   *@param {string} path
   *@returns {{dir:string,filename:string}}
   */
  function split_path(path) {
    var res = mp.utils.split_path(path);
    if(res.length !== 2) {
      mp.msg.fatal("不是正确的path: ",path)
    }
    return {
      dir: res[0],
      filename: res[1],
    };
  }

  /**
   * @param {string} dir
   * @param {string} filename
   * @returns {Record}
   */
  function get_record(dir, filename) {
    if (!filename || filename === "undefined" || dir === ".") return null;
    var dirHashObj = dirHash(dir);
    var dirData = data[dirHashObj.key]
    if(!dirData) return null
    var record_idx = findIndex(dirData.records,function(val) {
      return val.filename === filename
    })

    return record_idx !== -1 ? dirData.records[record_idx] : null
  }

  function create_record(dir, filename, time, percent_pos) {
    if (!filename || filename === "undefined" || dir === ".") return;
    var dirHashObj = dirHash(dir);
    var isNewDir = !data[dirHashObj.key];
    if (isNewDir) {
      var total_count = count_video_files(dir);
      data[dirHashObj.key] = {
        dir: dirHashObj.dir,
        records: [],
        total_count: total_count
      };
    }
    
    var dirData = data[dirHashObj.key];

    dirData.records.push({
      filename: filename,
      time: time,
      percent_pos: percent_pos
    });
  }

  function get_dirData(dir) {
    var dirHashObj = dirHash(dir);
    // dump(dir,dirKey)
    return data[dirHashObj.key]
  }

  function file_loaded(e) {
    var start_path = mp.get_property_native("path");
    if (!start_path) return;
    path = start_path;
    var file_info = split_path(path);
    var track = JSON.parse(mp.get_property("track-list"))[0];
    // dump(track)
    if(track.image) isImage = true
    if(track.type === "audio") isAudio = true
    var record = get_record(file_info.dir, file_info.filename);
    if (!record) return;
    mp.commandv("seek", record.time, "absolute", "exact");
  }

  function save_record() {
    if (!path) return;
    var file_info = split_path(path);
    if (isImage || isAudio) return;
    var adjustedTime = Math.max(0, (last_time_pos || 0) - 10);
    var record = get_record(file_info.dir, file_info.filename);
    if (!record) {
      create_record(file_info.dir, file_info.filename, adjustedTime,percent_pos);
    } else {
      record.time = adjustedTime;
      record.percent_pos = percent_pos;
    }
    
    cleanup_completed_dirs();
  }

  load_data();
  cleanup_old_completed(30);

  var last_time_pos;
  mp.observe_property("time-pos", "native", function (e, v) {
    if(v) last_time_pos = v;
  });

  var percent_pos;
  mp.observe_property("percent-pos","native",function(e,v) {
    if(v){
      percent_pos = Math.round(v)
    }
  })

  mp.register_event("end-file", function(){
    save_record()
    path = undefined;
    isImage = undefined;
  });

  mp.register_event("file-loaded", file_loaded);

  mp.register_event("shutdown", function () {
    save_data();
  });

  mp.add_key_binding("", "records-list", list_records);
  
  mp.register_script_message("cleanup-records", function() {
    var count = cleanup_completed_dirs();
    var old_count = cleanup_old_completed(30);
    mp.osd_message("清理完成: " + count + " 个已完成目录, " + old_count + " 个过期记录", 3000);
  });
})();
