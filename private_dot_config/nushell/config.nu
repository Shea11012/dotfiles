# config.nu
#
# Installed by:
# version = "0.104.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.config.show_banner = false
$env.config.shell_integration.osc133 = false

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

just --completions nushell | save -f ($nu.data-dir | path join "vendor/autoload/just.nu")

mise activate nu | save -f ($nu.vendor-autoload-dirs.1 | path join "mise.nu")
carapace _carapace nushell | save -f ($nu.vendor-autoload-dirs.1 | path join "carapace.nu")

# vfox activate nushell $nu.vendor-autoload-dirs.1 | ignore

navi widget nushell | save -f ($nu.vendor-autoload-dirs.1 | path join 'navi-widget.nu')

alias rsync = ^rsync -e D:/scoop/apps/cwrsync/current/bin/ssh.exe

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cw.XXXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}
