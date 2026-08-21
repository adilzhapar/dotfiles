#!/bin/zsh

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"


# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use zsh-bat)
source $ZSH/oh-my-zsh.sh

# User configuration
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk

# Path modifications
export PATH="$PATH:/opt/homebrew/opt/postgresql@16/bin"
export PATH="$PATH:$HOME/.rbenv/bin"
export PATH="$PATH:/Users/adilzhapar/.local/bin"
export PATH="$PATH:/opt/homebrew/opt/ruby@3.1/bin"
export PATH=$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH

# Aliases
alias l="lsd -a -l"
alias dc="docker compose"
alias p="pnpm"
alias n="nvim"
alias cl="clear"
alias ca="cursor-agent"

# Tool initializations
eval "$(zoxide init zsh --cmd j)"
eval "$(rbenv init -)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/Users/adilzhapar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pnpm end
export PATH="$HOME/.local/bin:$PATH"

# export PATH="/opt/homebrew/Cellar/postgresql@16/16.10/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
