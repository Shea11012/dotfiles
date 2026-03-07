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
    var parts = dir.split('/').filter(function(v) {
     return v !== ""; 
    });
    
    // 从最后部分开始，逐步向前扩展
    for (var len=parts.length-1;len>=0;len--) {
      var subDir = parts.slice(len).join('/');
      if(subDir.length < 5) continue;
      var hashStr = hash(subDir);
      var existingDirData = data[hashStr];
      if(!existingDirData) {
        return {
          key: hashStr,
          dir: subDir,
        };
      }
    }

    // 返回完整路径hash
    return {
      key: hash(dir),
      dir: dir,
    }
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
    var file_info = split_path(path)
    var records = get_dirData(file_info.dir).records
    var menu_data = {
      type: "records",
      title: "记录列表",
      callback: [mp.get_script_name(),"record-event"]
    }
    var items = [];
    for(var i=0;i<records.length;i++) {
      var record = records[i]
      items.push({
        title: record.filename + "  " + record.percent_pos + "%",
        value: record.filename
      }) 
    }

    menu_data.items = items;
    return menu_data
  }

  function list_records() {
    var menu_data = create_menu_data();
    if(menu_data.length === 0) {
      mp.osd_message("无记录",3000)
      return
    }
	  mp.commandv("script-message-to", "uosc", "open-menu", JSON.stringify(menu_data))
  }

  mp.register_script_message("record-event",function(value) {
    var event = JSON.parse(value);
    if(event.type === "activate" && event.action === undefined) {
      var playlists = mp.get_property_native("playlist")
      var idx = findIndex(playlists,function(val) {
        var filename = val.filename.substring(2)
        return filename === event.value
      })
      if(idx !== -1) mp.commandv("playlist-play-index",idx)
    }
  })

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
    // print("str: ",str)
    var filename = get_filename();
    // print("filename: ",filename)
    mp.utils.write_file("file://" + filename, str);
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

  function create_record(dir, filename, time,percent_pos) {
    if (!filename || filename === "undefined" || dir === ".") return;
    var dirHashObj = dirHash(dir);
    if (!data[dirHashObj.key]) {
      data[dirHashObj.key] = {
        dir: dirHashObj.dir,
        records: [],
      };
    }
    var dirData = data[dirHashObj.key]

    dirData.records.push({
      filename: filename,
      time: time,
      percent_pos: percent_pos
    })
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
    // 将last_time_pos 往回拨点
    var adjustedTime = Math.max(0, (last_time_pos || 0) - 10);
    var record = get_record(file_info.dir, file_info.filename);
    if (!record) {
      create_record(file_info.dir, file_info.filename, adjustedTime,percent_pos);
    } else {
      record.time = adjustedTime;
      record.percent_pos = percent_pos;
    }
  }

  load_data();

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

  mp.add_key_binding("","records-list",list_records);
})();
