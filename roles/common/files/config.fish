if status is-interactive
    set --erase fish_greeting
    printf "\nFailed Units:\n"
    systemctl list-units --failed
    printf "\nFailed Timers:\n"
    systemctl list-timers --failed
    printf "\nHealth:\n"
    sanoid --monitor-snapshots
    sanoid --monitor-health
    printf "\n"
    set --export EDITOR nvim
    set --export BAT_THEME OneHalfLight
    set --export VISUAL $EDITOR
    set --export LESS -RSMsi
    alias mkdir="mkdir --parents"
    alias cp="cp --recursive"

    alias f=fdfind

    if type --quiet (which exa)
        alias ls="exa"
        alias ll="exa -al --time-style long-iso"
        alias llg="exa -al --time-style long-iso --group"
        alias tr="exa -TL"
        alias tl="exa -lTL"
    else
        alias ls="ls -hv --color"
        alias ll="ls -alhv --color"
        alias tr="tree -CL"
        alias tl="tree -ugpCL"
    end

    if type --quiet (which batcat)
        alias c="batcat --paging=never --plain"
    end

    if type --quiet (which rg)
        alias g="rg"
    else
        alias g="grep"
    end
    function syncds --description 'Sync dataset to backup'
        set ds $argv[1]
        systemd-run --pty --collect --service-type=oneshot --unit=syncds-$ds /usr/sbin/syncoid --preserve-recordsize --no-sync-snap --compress=none --recursive data/$ds backup/$ds
    end
    function cd-vol --description 'Go to volume mount'
        set dir (cat /etc/mtab|g "data/$argv(\s+)"|awk '{ print $2 }')
        cd $dir
    end
    function eng --description 'Run with english locale'
        set --local --export LANG "en_US.utf8"
        eval $argv
    end
    function last-boot-errors --description 'Print errors from last boot'
        journalctl --no-pager --boot -1 --priority=err | g --invert-match sshd
    end
end
