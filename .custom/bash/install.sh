# ------------------------------- DEPENDENCIES --------------------------------

install_deps() {
    sudo pacman -Su --needed base-devel \
        openssl \
        curl \
        wget \
        autoconf \
        libtool \
        pkg-config \
        cmake \ gcc \
        g++ \
        make \
        xclip \
        ripgrep \
        xorg-server \
        mesa \ 
        tree \
        blueman \
        pavucontrol \
        discord
}

# -------------------------------- LANGUAGES ----------------------------------

install_python() {
    sudo pacman -Su --needed python
    pip3 install --user virtualenv virtualenvwrapper
}

install_rust() {
    sudo pacman -Su --needed rustup
}

install_golang() {
    sudo pacman -Su --needed go 
}

install_java() {
    sudo apt install --needed jre-openjdk
}

install_node() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
}

install_langs() {
    install_python
    install_rust
    install_golang
    install_java
    install_node
}

# ---------------------------------- TOOLS ------------------------------------

install_tmux() {
    sudo pacman -Su --needed tmux
    pushd "$HOME"
    git clone https://github.com/gpakosz/.tmux
    ln -s -f .tmux/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    popd  # $HOME
}

install_neovim() {
    pushd "$(mktemp -d)"
    sudo pacman -Su --needed vim neovim
    pip3 install --user neovim
    popd
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

install_gcloud() {
    sudo pacman -Su --needed google-cloud-sdk
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
    install_gcloud
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
