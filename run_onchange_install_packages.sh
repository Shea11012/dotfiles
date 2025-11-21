#!/usr/bin/env bash

# termux-change-repo 可以改变仓库镜像

# install tools
pkg update -y
pkg install git wget curl openssh python termux-services neovim ripgrep fd yazi bat xh

# 设置自启, 默认端口是 8022
sv-enable sshd

# 下载公钥
PUB_KEY=$(xh -b https://github.com/Shea11012.keys)
echo -e "$PUB_KEY\n" > ~/.ssh/authorized_keys

# 在Documents中创建rime
mkdir -p ~/storage/shared/Documents/input/rime
# 下载万象输入法的更新脚本
cd ~/storage/shared/Documents/input && xh -d https://github.com/rimeinn/rime-wanxiang-update-tools/releases/latest/download/rime-wanxiang-update-win-mac-ios-android.py
