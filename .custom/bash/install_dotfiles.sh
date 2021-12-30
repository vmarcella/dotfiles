#
# $HOME/.custom/bash/install_dotfiles.sh
# Install's dotfiles from https://github.com/vmarcella/dotfiles
#
# This script comes from: https://www.atlassian.com/git/tutorials/dotfiles

# ----------------------------------- FETCH ------------------------------------

config() {
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

pushd "$HOME" > /dev/null

echo ".dotfiles" >> .gitignore

git clone --bare --recurse-submodules \
    https://github.com/vmarcella/dotfiles $HOME/.dotfiles

# ----------------------------------- BACKUP -----------------------------------

mkdir -p .dotfiles-backup
config checkout 2>&1 \
    | egrep "\s+\." \
    | awk {'print $1'} \
    | xargs -I{} mv {} .dotfiles-backup/{}

# ---------------------------------- COMPLETE ----------------------------------

config checkout
config config --local status.showUntrackedFiles no

popd > /dev/null  # $HOME
