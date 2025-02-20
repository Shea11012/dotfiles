# schtasks /create /tn "rclone" /tr "powershell.exe -WindowStyle hidden -Command rclone mount alist: Z: --cache-dir D:\alist-cache --vfs-cache-mode writes --local-no-sparse"  /sc onlogon /f

$targetDir = "D:alist-cache"
if (-not (Test-Path -Path $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

rclone mount alist: Z: `
    --cache-dir 'D:\alist-cache' `
    --vfs-cache-mode writes `
    --local-no-sparse `
    --log-file 'D:\alist-cache\rclone.log' `
    --log-level INFO `
    # --volname "Alist云存储" `
    # --allow-other