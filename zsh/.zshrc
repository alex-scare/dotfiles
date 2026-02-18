typeset -U path PATH  # dedupe PATH entries
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Soome other configurations
export LANG="en_US.UTF-8"
export DYLD_LIBRARY_PATH="/usr/local/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"

export EDITOR="nvim"

# tmux configuration
alias tlearn='tmux a -t learn'
TMUX_STATUS_BAR="$HOME/.config/tmux/TMUX_STATUS_BAR"
export TMUX_TMPDIR="$HOME/.tmux/sessions"

# fzf configuration
export FZF_DEFAULT_OPTS='--walker-skip=".git,node_modules,target,dist,build,Library,Pods,fvm,flutter/packages,go/pkg"'
fzs() {
  local file
  file="$(fzf --preview='bat -n --color=always {}')" || return
  nvim "$file"
}

# starship
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
