test ! -e "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.
function is_wsl
  if rg -i 'microsoft|wsl' /proc/version >/dev/null
    return 0
  end

  if set -q WSL_DISTRO_NAME || set -q WSL_INTEROP
    return 0
  end

  return 1
end

if status is-interactive
  if not type -q fisher
    echo "install fisher"
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher   
  end

  # 配置tool
  mise activate fish | source
  zoxide init --cmd cd fish | source
  starship init fish | source
  uv generate-shell-completion fish | source

  if not is_wsl
    # set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock
    set -gx BROWSER librewolf
  end
end
