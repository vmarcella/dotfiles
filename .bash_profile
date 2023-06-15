#
# ~/.bash_profile
#
# eval `keychain --eval --agents ssh id_ed25519`


[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -e /home/cenz/.nix-profile/etc/profile.d/nix.sh ]; then . /home/cenz/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
. "$HOME/.cargo/env"
