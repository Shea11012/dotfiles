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

  if not test -e ~/.config/fish/completions/mise.fish
    echo "generate completion for mise"
    mise completion fish > ~/.config/fish/completions/mise.fish
  end

  if not test -e ~/.config/fish/completions/chezmoi.fish
    echo "generate completion for chezmoi"
    chezmoi completion fish > ~/.config/fish/completions/chezmoi.fish
  end

  if not test -e ~/.config/fish/completions/procs.fish
    echo "generate completion for procs"
    procs --gen-completion-out fish > ~/.config/fish/completions/procs.fish
  end
  
  if not test -e ~/.config/fish/completions/just.fish
    echo "generate completion for just"
    just --completions fish > ~/.config/fish/completions/just.fish
  end

  if not test -e ~/.config/fish/completions/atlas.fish
    echo "generate completion for atlas"
    atlas completion fish > ~/.config/fish/completions/atlas.fish
  end

  # 配置全局变量
  set -g fish_greeting
  set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock
  set -gx EDITOR "nvim"
  set -gx RUSTUP_DIST_SERVER "https://rsproxy.cn"
  set -gx  RUSTUP_UPDATE_ROOT "https://rsproxy.cn/rustup"

  # alias
  alias ls="lsd"
  alias ll="ls -la"
  # alias microsoft-edge="microsoft-edge-stable"
  alias rime-deploy='qdbus6 org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/deploy" ""'
  alias rime-sync='qdbus6 org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/sync" ""'
end



