if status is-interactive
    set --erase fish_greeting
    switch (whoami)
        case "dmp"
            set --export fish_user_paths ~/.local/bin /var/lib/flatpak/exports/bin
            set --export GPG_TTY (tty)
            function server --description 'Connect as root to the home server'
                ssh root@dm-poepperl.de $argv
            end
            alias o="xdg-open"
        case "root"
            printf "\nFailed Units:\n"
            systemctl list-units --failed
            printf "\nFailed Timers:\n"
            systemctl list-timers --failed
            printf "\n\n"
            if test -b /dev/sda
                smartctl -a /dev/sda | awk '/Percent_Lifetime_Remain/ {printf "Remaining Lifetime: %i %%\n",$4}'
            end
    end
    set --export EDITOR nvim
    set --export BAT_THEME OneHalfLight
    set --export VISUAL $EDITOR
    set --export LESS "-RSMsi"
    alias mkdir="mkdir --parents"
    alias cp="cp --recursive"

    alias f=fdfind
    alias f=fd

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
    function eng --description 'Run with english locale'
        set --local --export LANG "en_US.utf8"
        eval $argv
    end
    function last-boot-errors --description 'Print errors from last boot'
        journalctl --no-pager --boot -1 --priority=err | g --invert-match sshd
    end
    function hist --description 'Search the history'
        g $argv ~/.local/share/fish/fish_history
    end
end
