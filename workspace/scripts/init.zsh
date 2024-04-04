# Update aur package by select
function paru_update() {
    paru -Qauq | fzf -m | xargs -ro paru -S
}

# Clean unused package
function paru_clean() {
    paru -Qdtq | paru -Rns -
    paru -Qqd | paru -Rsu -
}

function update_archlinuxcn_mirrors() {
    tmpFile=$(mktemp)
    rate-mirrors --save=$tmpFile archlinuxcn
    sudo mv $tmpFile /etc/pacman.d/archlinuxcn-mirrorlist
    paru -Sc --aur --noconfirm
}

