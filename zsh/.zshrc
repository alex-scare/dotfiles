typeset -U path PATH  # dedupe PATH entries
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

export LANG="en_US.UTF-8"
export EDITOR="nvim"


# fzf configurations 
export FZF_DEFAULT_OPTS='--walker-skip=".git,node_modules,target,dist,build,Library,Pods,fvm,flutter/packages,go/pkg"'
ff() {
  local file
  file="$(fzf --preview='bat -n --color=always {}')" || return
  nvim "$file"
}

if [[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
elif [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source "/usr/share/fzf/key-bindings.zsh"
else
  bindkey -M emacs '^R' history-incremental-search-backward
  bindkey -M viins '^R' history-incremental-search-backward
fi

# end of fzf configuration


# starship
eval "$(starship init zsh)"
