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

    if type --quiet nvim
        set editor nvim
    else if type --quiet vim
        set editor vim
    else
        set editor vi
    end
    set --export EDITOR $editor
    set --export VISUAL $editor
    set --export BAT_THEME OneHalfLight
    set --export LESS -RSMsi
    alias mkdir="mkdir --parents"
    alias cp="cp --recursive"

    if type --quiet fdfind
        alias f=fdfind
    end

    if type --quiet exa
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

    if type --quiet batcat
        alias c="batcat --paging=never --plain"
    end

    if type --quiet rg
        alias g="rg"
    else
        alias g="grep"
    end

    function syncds --description 'Sync dataset to backup'
        set ds $argv[1]
        systemd-run --pty --collect --service-type=oneshot --unit=syncds-$ds /usr/sbin/syncoid --preserve-recordsize --no-sync-snap --compress=none --recursive data/$ds backup/$ds
    end

    function eng --description 'Run with english locale'
        set --local --export LANG "en_US.utf8"
        eval $argv
    end

    function last-boot-errors --description 'Print errors from last boot'
        journalctl --no-pager --boot -1 --priority=err | g --invert-match sshd
    end
end
