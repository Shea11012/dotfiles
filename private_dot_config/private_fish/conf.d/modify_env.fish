# 配置全局变量
set -g fish_greeting
set -gx EDITOR "nvim"
set -gx RUSTUP_DIST_SERVER "https://rsproxy.cn"
set -gx RUSTUP_UPDATE_ROOT "https://rsproxy.cn/rustup"
set -gx MANPAGER "nvim +Man!"
{{- /* chezmoi:modify-template */ -}}
{{ .chezmoi.stdin | replaceAllRegex "set -x GithubToken .*" (printf "set -x GithubToken %s" (fromToml (joinPath .chezmoi.sourceDir "workspace/mxy/dotfiles/encrypted_env.toml.age" | include | decrypt)).GithubToken | toString )}}
