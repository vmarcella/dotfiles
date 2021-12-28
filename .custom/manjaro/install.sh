# ------------------------------- DEPENDENCIES --------------------------------

install_deps() {
    sudo pacman -Su --needed base-devel \
        openssl \
        curl \
        wget \
        autoconf \
        libtool \
        pkg-config \
        cmake \
        gcc \
        make \
        xclip \
        ripgrep \
        xorg-server \
        mesa \
        tree \
        blueman \
        pavucontrol \
        discord \
        doxygen \
        graphviz \
        git-lfs
}

# -------------------------------- LANGUAGES ----------------------------------

install_python() {
    sudo pacman -Su --needed python-pip
    pip3 install --user virtualenv virtualenvwrapper
}

install_rust() {
    sudo pacman -Su --needed rustup
}

install_golang() {
    sudo pacman -Su --needed go 
}

install_java() {
    sudo pacman -Su --needed jre-openjdk
}

install_node() {
    local NVM_DIR="$HOME/.nvm"
    if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
        curl -o- \
            https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh \
            | bash

        nvm install 16
    fi
}

install_langs() {
    install_python
    install_rust
    install_golang
    install_java
    install_node
}


# ---------------------------------- TOOLS ------------------------------------

install_zsh() {
    sudo pacman -Su --needed zsh
}

install_tmux() {
    # Install tmux
    sudo pacman -Su --needed tmux

    # Install oh-my-tmux
    pushd "$HOME" > /dev/null
    git clone https://github.com/gpakosz/.tmux
    ln -s -f .tmux/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    popd > /dev/null  # $HOME
}

install_neovim() {
    sudo pacman -Su --needed vim neovim

    mkdir -p "$HOME/.vim/swap"
    mkdir -p "$HOME/.vim/backup"

    pip3 install --user neovim
}

install_vim_plugged() {
    curl -fLo  ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_powerline_status() {
    sudo pacman -Su --needed powerline
}

install_docker() {
    sudo pacman -Su --needed docker
    sudo usermod -a -G docker "$USER"
    sudo systemctl start docker
    sudo systemctl enable docker
}

install_bazel() {
    sudo pacman -Su --needed bazel
}

install_clangd() {
    sudo pacman -Su --needed clang
}

install_tools() {
    install_tmux
    install_neovim
    install_vim_plugged
    install_powerline_status
    install_docker
    install_bazel
    install_clangd
}

# ---------------------------------- RUNNER -----------------------------------

install() {
    install_deps
    install_langs
    install_tools
    sudo pacman -Sc
}

install
