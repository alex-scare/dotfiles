typeset -U path PATH  # dedupe PATH entries
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

export LANG="en_US.UTF-8"
export EDITOR="nvim"

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi


# fzf configurations 
export FZF_DEFAULT_OPTS='--walker-skip=".git,node_modules,target,dist,build,Library,Pods,fvm,flutter/packages,go/pkg"'
export FZF_COMPLETION_TRIGGER='~~'

autoload -Uz compinit
compinit

ff() {
  local file
  file="$(fzf --preview='bat -n --color=always {}')" || return
  nvim "$file"
}

killport() {
  for port in "$@"; do
    pids=$(lsof -tiTCP:"$port" -sTCP:LISTEN)

    if [ -z "$pids" ]; then
      echo "No process listening on port $port"
      continue
    fi

    echo "Killing port $port: $pids"
    kill -9 $pids
  done
}

if [[ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]]; then
  source "/opt/homebrew/opt/fzf/shell/completion.zsh"
elif [[ -f "/usr/share/fzf/completion.zsh" ]]; then
  source "/usr/share/fzf/completion.zsh"
fi

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
