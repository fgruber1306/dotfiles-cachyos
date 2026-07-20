# Oni · .zshrc

# ── Prompt: fabi@oni ~/path ❯  (mint/ice, matches the rice) ──
PROMPT='%F{#5fe0c0}%n@%m %F{#9db8c4}%~ %F{#5fe0c0}❯%f '

# ── History ──
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE APPEND_HISTORY

# ── Completion ──
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive

# ── Keybinds ──
bindkey -e                       # emacs mode (default-ish, sane)
bindkey '^[[3~' delete-char      # Del key

# ── Aliases ──
alias v='vim'
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias nas='ssh Fabi@192.168.188.88'
alias vpn-status='curl -s ifconfig.me; echo'
alias update='sudo pacman -Syu'

# ── Optional plugins (installed via pacman, loaded only if present) ──
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#66716e'

fastfetch
