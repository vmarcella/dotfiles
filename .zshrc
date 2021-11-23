# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------- ZINIT ------------------------------------


# ------------------------------- ZINIT PLUGINS --------------------------------
# Load a few important annexes, without Turbo
# (this is currently required for annexes)
### Added by Zinit's installer

if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk

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


# Add the new .local/bin folder to the path for user specific data (weird)
export PATH="$HOME/.custom/scripts:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/zig:$PATH"
export EDITOR=nvim
export TERM=xterm-256color

# Node virtual env setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion"  # This loads nvm bash_completion

# ----------------------------------- ALIASES ----------------------------------

# Tmux aliases
alias tattach="tmux attach-session -t"
alias tkill="tmux kill-session -t"
alias tnew="tmux new -s"
alias tdetach="tmux detach"

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias start_keychain='eval `keychain --eval --agents ssh id_ed25519 id_rsa azlinux`'

alias steam='flatpak run --filesystem=/yeet com.valvesoftware.Steam'

# Pats factorio server connection info.
alias factorio_server_connect='wg-quick up /etc/wireguard/wg0.conf'
alias factorio_server_disconnect='wg-quick down /etc/wireguard/wg0.conf'

# ---------------------------------- FUNCTIONS ---------------------------------

#Vim wrapper to allow control keys to be passed to vim
vim() {
        # osx users, use stty -g
        local STTYOPTS="$(stty --save)"
        stty stop '' -ixoff
        command nvim "$@"
        stty "$STTYOPTS"
}

autoload -Uz compinit
compinit
zstyle ':completion:*' menu select