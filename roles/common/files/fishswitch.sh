# $- holds active shell flags; 'i' means interactive — skip for non-interactive shells (e.g. ssh host command)
[[ $- == *i* ]] || return

# Forced-interactive command strings (bash -ic '...') must not switch — VS Code probes the environment this way
[[ -z "${BASH_EXECUTION_STRING:-}" ]] || return

# Only applies to remote sessions; SSH_CONNECTION covers VS Code remote terminals, where SSH_TTY is unset
[[ -n "${SSH_TTY:-}" || -n "${SSH_CONNECTION:-}" ]] || return

# Don't switch if already in fish, or if bash was deliberately started from fish
[[ -n "${FISH_VERSION:-}" || "$(ps -o comm= -p $PPID 2>/dev/null)" == "fish" ]] && return

command -v fish >/dev/null 2>&1 && exec fish -l
