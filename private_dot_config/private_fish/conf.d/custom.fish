if not status is-interactive
    return
end

set tools atlas chezmoi just mise procs

for item in $tools
    set filename (printf "%s/.config/fish/completions/%s.fish" $HOME $item)

    if test -e "$filename"
        continue
    end

    printf "generate completion for %s\n" $item
    switch $item
    case "atlas"
        atlas completion fish > $filename 
    case "chezmoi"
        chezmoi completion fish > $filename
    case "just"
        just --completions fish > $filename
    case "mise"
        mise completion fish > $filename
    case "procs"
        procs --gen-completion-out fish > $filename
    end
end

# Update aur package by select
function paru_update -d "update specify package"
    paru -Qauq | fzf -m | xargs -ro paru -S
end

# Clean unused package
function paru_clean -d "clean unused package"
    paru -Qdtq | paru -Rns -
    paru -Qqd | paru -Rsu -
    sudo paccache -rk3
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

