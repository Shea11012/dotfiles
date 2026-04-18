oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/star.omp.json" | Invoke-Expression

Invoke-Expression (&sfsu hook)

$env:GOBREW_REGISTRY = "https://golang.google.cn/dl/"
$env:RUSTUP_DIST_SERVER = "https://rsproxy.cn"
$env:RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup"

$a = @("rm", "del", "dir", "cat", "pwd", "mv", "ls", "kill")
Remove-Alias -Name $a

function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}

function Get-ls {
    if ($args[0] -eq "") {
        lsd -l
    }
    else {
        lsd -l $args
    }
}

function Get-lt($n = 2) {
    lsd --tree --depth $n
}
Set-Alias -Name ls -Value lsd
Set-Alias -Name ll -Value Get-ls
Set-Alias -Name lt -Value Get-lt
Set-Alias -Name make -Value just
Set-Alias -Name rsync -Value customRsync

function customRsync {
    & rsync.exe -e 'D:/scoop/apps/cwrsync/current/bin/ssh.exe' @args
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression "$(vfox activate pwsh)"
