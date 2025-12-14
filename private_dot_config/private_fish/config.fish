if not status is-interactive
  return
end

if not functions -q fisher
  echo "install fisher"
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher   
end

test ! -f "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.

function is_wsl --description "Check if running in WSL"
  if string match -q -r "microsoft|wsl" < /proc/version
    return 0
  else if set -q WSL_DISTRO_NAME || set -q WSL_INTEROP
    return 0
  end

  return 1
end

if not is_wsl
  # set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock
  set -gx BROWSER zen-browser
end

fzf_configure_bindings --git_status= --git_log= --directory= --processes= --variables=

# 配置tool
mise activate fish | source
# zoxide init --cmd cd fish | source
zoxide init fish | source
starship init fish | source
uv generate-shell-completion fish | source
# 自定义cheat补全
navi widget fish | source
# 补全工具
carapace _carapace | source
# 新版本管理工具
jj util completion fish | source
# 自动加载环境变量
direnv hook fish | source
