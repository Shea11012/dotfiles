#!/usr/bin/env bash

alist_target=/home/mxy/rclone/alist
# onedrive_target=/home/mxy/rclone/onedrive
expect_uuid="c037f03d-4541-4207-ac1b-2661dae52086"

remote=""
host="http://192.168.32.100:5244"
function mount_alist() {
	check_rime
	if nm-online -q -t 30; then
		pong=$(xh -b "$host/ping")
		# uuid=$(nmcli -g UUID,TYPE c show --active | rg "wireless" | cut -d ":" -f 1)
		# if [[ $uuid == "$expect_uuid" ]]; then
		if [[ "$pong" == "pong" ]]; then
			rclone mount "$remote:" "$alist_target" "$mount_opt"
		else
			# echo "actual uuid: $uuid, expect uuid: $expect_uuid"
			echo "ping fail: $host"
		fi
	else
		echo "network not available"
	fi
}

function umount_alist() {
	umount "$alist_target"
}

check_rime() {
	if [[ $(fd --max-depth 1 -td '' ~/rclone/alist | wc -l) -gt 0 ]]; then
		rm -rf ~/rclone/alist/*
	fi
}

# function mount_onedrive() {
# 	if [[ $(fd --max-depth 1 -td '' ~/rclone/onedrive | wc -l) -gt 0 ]]; then
# 		rm -rf ~/rclone/onedrive/*
# 	fi
#
# 	if ! rclone mount "$remote:" "$onedrive_target" --vfs-cache-mode writes --daemon; then
# 		notify-send "rclone" "onedrive mount failed"
# 	fi
# }
#
# function umount_onedrive() {
# 	umount "$onedrive_target"
# }

f=""
while [[ "$#" -gt 0 ]]; do
	case $1 in
	--mount)
		remote=$2
		f="mount_$2"
		shift
		;;
	--umount)
		remote=$2
		f="umount_$2"
		shift
		;;
	*)
		echo "unknown parameter passed: $1"
		exit 1
		;;
	esac
	shift
done

$f
