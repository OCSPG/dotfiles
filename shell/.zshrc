# ~/.zshrc - Clean ZSH configuration

# Basic ZSH options
setopt AUTO_CD              # Change directory just by typing directory name
setopt HIST_VERIFY          # Show command with history expansion to user before running it
setopt SHARE_HISTORY        # Share command history data
setopt HIST_IGNORE_SPACE    # Ignore commands that start with space
setopt HIST_IGNORE_DUPS     # Ignore duplicate commands
setopt HIST_FIND_NO_DUPS    # Don't show duplicates in search
setopt COMPLETE_IN_WORD     # Complete from both ends of a word
setopt ALWAYS_TO_END        # Move cursor to end if word had one match

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Add user bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Case-insensitive completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Load syntax highlighting (must be near end)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load autosuggestions (must be after syntax highlighting)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Autosuggestion settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Initialize zoxide
eval "$(zoxide init zsh)"

# Initialize starship prompt
eval "$(starship init zsh)"

# Modern CLI tool aliases - replace traditional commands with improved versions
# Core file operations
alias ls='eza --group-directories-first'
alias ll='eza -l --group-directories-first'  
alias la='eza -la --group-directories-first'
alias lt='eza --tree --group-directories-first'
alias cat='bat --paging=never'
alias less='bat'

# Text processing and search
alias grep='rg'
alias find='fd'
alias sed='sd'

# System monitoring and process management
alias ps='procs'
alias top='btm'
alias htop='btm'
alias du='dust'
alias df='duf'

# Network tools
alias ping='gping'
alias dig='dog'
alias curl='curlie'

# Git enhancements (if using git-delta)
alias diff='delta'

# Development and analysis tools
alias time='hyperfine'
alias count='tokei'
alias man='tldr'

# JSON/YAML processing
alias json='jq'
alias yaml='yq'

# Interactive tools (keep originals available)
alias fzf-find='fd --type f | fzf'
alias fzf-dir='fd --type d | fzf'

# Quick access to original commands if needed
alias ocat='command cat'
alias ols='command ls' 
alias ogrep='command grep'
alias ofind='command find'
alias ops='command ps'
alias otop='command top'
alias odu='command du'
alias odf='command df'
alias oping='command ping'
alias odig='command dig'
alias ocurl='command curl'
alias odiff='command diff'
alias oman='command man'

# Additional modern tools
alias bandwhich='sudo bandwhich'  # Network bandwidth monitor
alias lnav-log='lnav'            # Log file navigator
alias choose='choose'            # Human-friendly cut alternative

# Navigation aliases
alias cd='z'  # Use zoxide for cd
alias ccd='builtin cd'  # Original cd for Claude Code

# Key bindings
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Auto-start Hyprland on first login (TTY1 only)
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec uwsm start hyprland.desktop
fi
export PATH="$PATH:$HOME/Scripts/utils"
alias todo="quick-claude TODO"
alias done="quick-claude DONE"
alias note="quick-claude NOTE"
alias idea="quick-claude IDEA"
alias qc="quick-claude"
