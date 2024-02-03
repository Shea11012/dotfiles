#!/usr/bin/env bash

smb_target=/home/mxy/rclone/smb
onedrive_target=/home/mxy/rclone/onedrive

remote=""
function mount_smb() {
	uuid=$(nmcli -g UUID,TYPE c show --active | rg "wireless" | cut -d ":" -f 1)
	if [[ $uuid == "$EXPECT_UUID" ]]; then
		rclone mount "$remote:share" "$smb_target" --cache-dir /tmp/rclone/smb --vfs-cache-mode full --daemon
	else
		echo "actual uuid: $uuid, expect uuid: $EXPECT_UUID"
	fi
}

function umount_smb() {
	umount "$smb_target"
}

function mount_onedrive() {
	rclone mount "$remote:" "$onedrive_target" --cache-dir /tmp/rclone/onedrive --vfs-cache-mode full --daemon
}

function umount_onedrive() {
	umount "$onedrive_target"
}

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
