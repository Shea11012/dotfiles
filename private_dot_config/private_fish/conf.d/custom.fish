# Update aur package by select
function paru_update -d "update specify package"
    paru -Qauq | fzf -m | xargs -ro paru -S
end

# Clean unused package
function paru_clean -d "clean unused package"
    paru -Rns (paru -Qqdt)
    sudo paccache -rk3
    paru -Sc --noconfirm
end

function update_mirrors -d "update arch and archlinuxcn mirrors"
    set tmpfile (mktemp)
    rate-mirrors --disable-comments-in-file --save=$tmpfile arch 
    sudo mv $tmpfile /etc/pacman.d/mirrorlist
    set tmpfile (mktemp)
    rate-mirrors --disable-comments-in-file --save=$tmpfile archlinuxcn
    sudo mv $tmpfile /etc/pacman.d/archlinuxcn-mirrorlist
end

# check last system update
function last_update -d "check system last update"
    rg 'system upgrade' /var/log/pacman.log | tail -n 1
end

function y -d "yazi shell wrapper"
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function check-gui
    if test (count $argv) -ne 1
        echo "用法：check-gui <程序名>"
        echo "示例：check-gui code"
        echo "      check-gui simple_live_app"
        return 1
    end

    set APP $argv[1]
    set PID (pidof $APP | awk '{print $1}')

    if test -z "$PID"
        echo "❌ 未找到运行中的程序：$APP"
        return 1
    end

    echo "🔍 程序：$APP"
    echo "🆔 PID：$PID"
    echo "----------------------------------------"

    set maps (cat /proc/$PID/maps)

    if echo "$maps" | rg -qi "libflutter_linux_gtk"
        echo "✅ Flutter + GTK3"
    else if echo "$maps" | rg -qi "chrome|ozone|electron"
        echo "✅ Electron / Chromium (VSCode)"
    else if echo "$maps" | rg -qi "qt.*\.so|PySide6|PyQt"
        echo "✅ Qt（Qt5/Qt6/PySide6/PyQt）"
    else if echo "$maps" | rg -qi "libgtk-3|libgtk-4"
        echo "✅ GTK3/GTK4"
    else if echo "$maps" | rg -qi "kf5|kf6|libKF"
        echo "✅ KDE（基于 Qt）"
    else if echo "$maps" | rg -qi "tauri"
        echo "✅ Tauri"
    else
        echo "⚠️  未知框架"
    end
end
