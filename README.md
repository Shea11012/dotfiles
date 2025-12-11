# dotfiles

使用chezmoi管理dotfiles

# chezmoi 使用

`chezmoi init {git-url}`：初始化一个chezmoi仓库，如果已经有了仓库，则将git地址填入会自动pull下来

`chezmoi cd`：进入到仓库目录 `chezmoi add`：添加一个文件或目录到仓库

`chezmoi diff`：对比文件区别，以chezmoi仓库的文件为基准

`chezmoi apply`：将仓库文件修改更新对应的配置文件

# 必要软件

- zimfw：https://github.com/zimfw/zimfw
- mise: https://mise.jdx.dev
- paru: 替代pacman
- uutils-coreutils：rust 重写的coreutils
- lsd: 替代ls
- hyperfine: 替代time
- tealdeer: 替代tldr
- zoxide: 替代cd
- ouch: 解压缩工具
- dog：替代dig
- wezterm：终端
- zellij：替代tmuxer
- xh: 替代curl
- bat: 替代cat
- procs: 替代ps
- ripgrep: 替代grep
- fd: 替代find
- ncdu: 替代du
- wf-recorder: 录屏 https://github.com/ammen99/wf-recorder

# 配置archlinuxcn源

```bash
# /etc/pacman.conf 添加
[archlinuxcn]
Include = /etc/pacman.d/archlinuxcn-mirrorlist

# 更新
paru -Syyu & paru -S archlinuxcn-keyring
```

# 导出和导入Arch软件包

```bash
paru -Qqe > installed.txt
paru -S --needed - < installed.txt
```

# 删除不必要的包

```bash
# 删除不必要的包
paru -Qdtq | paru -Rns -

# 输出额外的不必要包，如需删除则移除--print参数
paru -Qqd | paru -Rsu --print -
```
