# Set $PATH 
export PATH=$HOME/.bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/kscr/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Zsh update frequency
export UPDATE_ZSH_DAYS=7

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# For a list of active aliases, run 'alias'.
#
# Personal aliases
alias zshconfig='vim ~/.zshrc'
alias i3config='vim ~/.config/i3/config'
alias pbconfig='vim ~/.config/polybar/config'
alias neofetch='neofetch --ascii ~/.config/neofetch/owoneofetch'

# Automatically start X upon login
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	exec startx
fi

# Set correct tty for GPG to use (not sure if this is necessary)
export GPG_TTY=$(tty)

# Python startup
export PYTHONSTARTUP=~/.pythonstartup
