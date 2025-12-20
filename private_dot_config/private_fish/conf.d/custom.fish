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
