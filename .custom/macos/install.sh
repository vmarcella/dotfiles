#!/bin/bash

install_brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_python() {
  brew install python@3.13 python@3.12 python-setuptools pipx
  pip3 install --user poetry neovim
}

install_rust() {
  curl https://sh.rustup.rs -sSf | sh
  rustup toolchain install stable
  rustup toolchain install nightly
}

install_node() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh \
    | bash

  nvm install 18.13.0
}

install_go() {
  brew install go
}

install_languages() {
  install_python
  install_rust
  install_node
  install_go
}

install_vscode() {
  brew install --cask visual-studio-code
}

install_vim_plugged() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_vim() {
    brew install neovim

    mkdir -p "$HOME/.vim/swap"
    mkdir -p "$HOME/.vim/backup"
    install_vim_plugged
}

install_tmux() {
    brew install tmux
    pushd "$HOME" > /dev/null
    git clone https://github.com/gpakosz/.tmux
    ln -s -f .tmux/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    popd > /dev/null  #$HOME
}

install_dev_tools() {
  install_vim
  install_vscode
  install_tmux

  # Install some dev tools
  brew install keychain cmake ninja azure-cli
  brew install --cask iterm2
  brew install --cask docker

  # Install aider using python3.12, as 3.13 is not yet supported.
  pipx install aider --python python3.12
}

install() {
  install_brew
  install_languages
  install_dev_tools
}
