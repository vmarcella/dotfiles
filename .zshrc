# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------- ZINIT PLUGINS --------------------------------

if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220}"\
        "Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit \
        "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node


# -------------------------------- ZINIT PLUGINS -------------------------------

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

zinit light romkatv/powerlevel10k
zinit light agkozak/zsh-z
zinit light supercrabtree/k
zinit light skx/sysadmin-util

# Load zsh-vim-mode and set the normal mode key to jj
VIM_MODE_VICMD_KEY='jj'
zinit load softmoth/zsh-vim-mode

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ----------------------------------- HISTORY ----------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# ----------------------------------- EXPORTS ----------------------------------

# The dotnet root seems to be located here when installing from 
# packages.microsoft.com
export DOTNET_ROOT="/usr/share/dotnet"

# Add the new .local/bin folder to the path for user specific data (weird)
export PATH="$HOME/.custom/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$DOTNET_ROOT:$PATH"
export EDITOR=nvim

# Node virtual env setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion"

# -------------------------------- DEPENDENCIES --------------------------------

source "$HOME/.custom/bash/common.sh"

# ---------------------------------- FUNCTIONS ---------------------------------

vim() {
    local STTYOPTS="$(stty -g)"
    stty stop '' -ixoff
    command nvim "$@"
    stty "$STTYOPTS"
}

autoload -Uz compinit && compinit
compdef _git config

zstyle ':completion:*' menu select

export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
alias gvm="$GOPATH/bin/g"; # g-install: do NOT edit, see https://github.com/stefanmaric/g

if [[ "$(uname -a)" =~ "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else 
  # TODO(vmarcella): Check if this works for other distributions in the future.
  export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
  eval "$($(brew --prefix)/bin/brew shellenv)"
fi
