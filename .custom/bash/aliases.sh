# Tmux aliases
alias tattach="tmux attach-session -t"
alias tkill="tmux kill-session -t"
alias tnew="tmux new -s"
alias tdetach="tmux detach"

alias config="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

alias start_keychain='eval `keychain --eval --agents ssh id_ed25519 id_rsa azlinux`'

alias steam="flatpak run --filesystem=/yeet com.valvesoftware.Steam"

alias factorio_server_connect="wg-quick up /etc/wireguard/wg0.conf"
alias factorio_server_disconnect="wg-quick down /etc/wireguard/wg0.conf"

# For Manjaro mirror configuration.
alias update_mirrors="sudo pacman-mirrors -c United_States"
