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
    rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist
    rate-mirrors archlinuxcn | sudo tee /etc/pacman.d/archlinuxcn-mirrorlist
end

function lt -d "show directory tree"
    argparse "d/depth=" -- $argv
    if not set -q _flag_d
        set _flag_d 2
    end

    if not [ -n $argv[1] ]
        set argv[1] $PWD
    end
    
    lsd -a --tree --depth $_flag_d $argv[1]
end
