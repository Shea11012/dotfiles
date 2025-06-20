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

  # 配置全局变量
  set -g fish_greeting
  set -gx EDITOR "nvim"
  set -gx RUSTUP_DIST_SERVER "https://rsproxy.cn"
  set -gx RUSTUP_UPDATE_ROOT "https://rsproxy.cn/rustup"
  set -gx MANPAGER "nvim +Man!"

  if not is_wsl
    # set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock
    set -gx BROWSER librewolf
  end

  # alias
  alias ls="lsd"
  alias ll="lsd -la"
  alias lt="lsd -a --tree"
  alias rime-deploy='qdbus6 org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/deploy" ""'
  alias rime-sync='qdbus6 org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/sync" ""'
end
