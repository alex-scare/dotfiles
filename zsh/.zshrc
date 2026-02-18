typeset -U path PATH  # dedupe PATH entries
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

export LANG="en_US.UTF-8"
export EDITOR="nvim"

# fzf configuration
export FZF_DEFAULT_OPTS='--walker-skip=".git,node_modules,target,dist,build,Library,Pods,fvm,flutter/packages,go/pkg"'
fzs() {
  local file
  file="$(fzf --preview='bat -n --color=always {}')" || return
  nvim "$file"
}

# starship
eval "$(starship init zsh)"
