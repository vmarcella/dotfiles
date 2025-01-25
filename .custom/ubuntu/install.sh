#!/bin/bash

install_deps() {
	sudo apt install \
		build-essential \
		libssl-dev \
		curl \
		wget \
		autoconf \
		libtool \
		pkg-config \
		libgflags-dev \
		apt-transport-https \
		cmake \
		g++ \
		make \
		xclip \
		ripgrep \
		xorg-dev \
		libglu1-mesa-dev \
		zsh \
		keychain \
		tree
}

install_python() {
	sudo apt install python3-pip python3-dev
	pip3 install --user virtualenv virtualenvwrapper
}

install_rust() {
	curl https://sh.rustup.rs -sSf | sh
	rustup toolchain install nightly
}

install_golang() {
	curl -sSL https://git.io/g-install | sh -s
}

install_java() {
	sudo apt install default-jdk
}

install_node() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh |
		bash

	nvm install 16.15.0
}

install_langs() {
	install_python
	install_rust
	install_golang
	install_java
	install_node
}

install_tmux() {
	sudo apt install tmux
	pushd "$HOME" >/dev/null
	git clone https://github.com/gpakosz/.tmux
	ln -s -f .tmux/.tmux.conf
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	popd >/dev/null #$HOME
}

install_neovim() {
  brew install neovim

	pip3 install --user neovim

	mkdir -p "$HOME/.vim/swap"
	mkdir -p "$HOME/.vim/backup"
}

install_vim_plugged() {
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_powerline_status() {
	sudo apt install powerline
}

install_docker() {
	sudo apt install docker.io
	sudo usermod -a -G docker "$USER"
	sudo systemctl start docker
	sudo systemctl enable docker
}

install_clangd() {
	sudo apt install clangd-10
}

install_brew() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_tools() {
	install_tmux
	install_neovim
	install_vim_plugged
	install_powerline_status
	install_docker
	install_clangd
	install_brew
}

install() {
	sudo apt update && sudo apt upgrade
	install_deps
	install_langs
	install_tools
	sudo apt autoremove
}

install
