if not status is-interactive
    return
end

for item in (fd . --base-directory ~/.config/fish/completions | string split -f1 '.')
    set filename (printf "~/.config/fish/completions/%s.fish" $item)
    if echo $filename | test -e
        continue
    end

    printf "generate completion for %s\n" $item
    switch $item
    case "atlas"
        atlas completion fish > ~/.config/fish/completions/atlas.fish
    case "chezmoi"
        chezmoi completion fish > ~/.config/fish/completions/chezmoi.fish
    case "just"
        just --completions fish > ~/.config/fish/completions/just.fish
    case "mise"
        mise completion fish > ~/.config/fish/completions/mise.fish
    case "procs"
        procs --gen-completion-out fish > ~/.config/fish/completions/procs.fish
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
