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

  if not is_wsl
    # set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock
    set -gx BROWSER zen-browser
  end
end

fzf_configure_bindings --git_status= --git_log= --directory= --processes= --variables=

# 配置tool
  mise activate fish | source
  # zoxide init --cmd cd fish | source
  zoxide init fish | source
  starship init fish | source
  uv generate-shell-completion fish | source
  navi widget fish | source
  carapace _carapace | source

