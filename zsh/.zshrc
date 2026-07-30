typeset -U path PATH  # dedupe PATH entries
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

export LANG="en_US.UTF-8"
export EDITOR="nvim"

# Set up NVM and select the default Node version for every new Zsh session.
# This overrides an inherited Node path (for example, from a GUI app such as Zed)
# so `node`, `npm`, and `bun` commands use the NVM default consistently.
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # Define the `nvm` shell function and its PATH integration.
  source "$NVM_DIR/nvm.sh"
  # Switch to the version named by `nvm alias default` (currently Node 24).
  nvm use default --silent
fi

# Enable NVM's optional tab completion when it is installed.
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
