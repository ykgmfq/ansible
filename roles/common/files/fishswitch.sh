# $- holds active shell flags; 'i' means interactive — skip for non-interactive shells (e.g. ssh host command)
[[ $- == *i* ]] || return

# Only applies to SSH sessions with an interactive terminal (SSH_TTY is more reliable than SSH_CONNECTION — cleared by some PAM/sudo configs)
[[ -n "${SSH_TTY:-}" ]] || return

# Skip VS Code Remote sessions
[[ -n "${VSCODE_IPC_HOOK_CLI:-}" || "${TERM_PROGRAM:-}" == "vscode" ]] && return

# Don't switch if already in fish
[[ -n "${FISH_VERSION:-}" || "${SHELL##*/}" == "fish" ]] && return

command -v fish >/dev/null 2>&1 && exec fish -l
