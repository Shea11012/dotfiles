# schtasks /create /tn "rclone" /tr "powershell.exe -WindowStyle hidden -Command rclone mount alist: Z: --cache-dir D:\alist-cache --vfs-cache-mode writes --local-no-sparse"  /sc onlogon /f

$targetDir = "D:\alist-cache"
$logFile = $targetDir + "\rclone.log"

if (Test-Path -Path $logFile) {
    Remove-Item $logFile
}

if (-not (Test-Path -Path $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

rclone mount alist: Z: `
    --cache-dir $targetDir `
    --vfs-cache-mode writes `
    --local-no-sparse `
    --log-file $logFile `
    --log-level INFO `
    # --volname "Alist云存储" `
    # --allow-other