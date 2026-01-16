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

  function dirHash(dir) {
    var hash = 0;
    for (var i = 0; i < dir.length; i++) {
      var char = dir.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      // 确保hash是一个32位有符号数
      hash = hash | 0;
    }
    return base36(abs(hash));
  }

  function get_filename() {
    var path = mp.utils.get_user_path("~~/");
    var file = mp.utils.join_path(path, filename);
    return file;
  }

  function file_exists(filename) {
    return !!mp.utils.file_info(filename);
  }

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
    var t = res[0].split("/").filter(function(v){
      return v !== ""
    })
    var dir = t[t.length-1]
    return {
      dir: dir,
      filename: res[1],
    };
  }

  /**
   * @param {string} dir
   * @param {string} filename
   * @returns {Record}
   */
  function get_progress(dir, filename) {
    if (!filename || filename === "undefined" || dir === ".") return null;
    var dirKey = dirHash(dir);
    var dirData = data[dirKey]
    if (dirData && dirData.records[filename]) {
      return dirData.records[filename] || null;
    }
    return null;
  }

  function create_record(dir, filename, time) {
    if (!filename || filename === "undefined" || dir === ".") return;
    var dirKey = dirHash(dir);
    if (!data[dirKey]) {
      data[dirKey] = {
        dir: dir,
        records: {},
      };
    }

    data[dirKey].records[filename] = {
      filename: filename,
      time: time,
    };
  }

  load_data();

  var last_time_pos;
  mp.observe_property("time-pos", "native", function (e, v) {
    v && (last_time_pos = v);
  });

  var path;
  var isVideo; // 需要在加载时就判断，否则在end-file和shutdown事件则会变为auto
  function file_loaded(e) {
    var start_path = mp.get_property_native("path");
    if (!start_path) return;
    path = start_path;
    var file_info = split_path(path);
    isVideo = mp.get_property_native("video") === 1; 
    var record = get_progress(file_info.dir, file_info.filename);
    if (!record) return;
    mp.commandv("seek", record.time, "absolute", "exact");
  }

  function save_record() {
    if (!path) return;
    var file_info = split_path(path);
    if (!isVideo) return;
    // 将last_time_pos 往回拨点
    var adjustedTime = Math.max(0, (last_time_pos || 0) - 10);
    var record = get_progress(file_info.dir, file_info.filename);
    if (!record) {
      create_record(file_info.dir, file_info.filename, adjustedTime);
    } else {
      record.time = adjustedTime;
    }
  }

  mp.register_event("end-file", function(){
    save_record()
    path = undefined;
    isVideo = undefined;
  });

  mp.register_event("file-loaded", file_loaded);

  mp.register_event("shutdown", function () {
    save_data();
  });
})();
