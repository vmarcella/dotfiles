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
        python3-dev \
        python-dev \
        ripgrep \
        xorg-dev \
        libglu1-mesa-dev
        tree
}

install_python() {
    sudo apt install python3-pip
    pip3 install --user virtualenv virtualenvwrapper
}

install_rust() {
    curl https://sh.rustup.rs -sSf | sh
}

install_golang() {
    curl -sSL https://git.io/g-install | sh -s
}

install_java() {
    sudo apt install default-jdk
}

install_node() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh \
        | bash
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
    pushd "$HOME" > /dev/null
    git clone https://github.com/gpakosz/.tmux
    ln -s -f .tmux/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    popd > /dev/null  #$HOME
}

install_neovim() {
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install neovim

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

install_bazel() {
    curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" \
        | sudo tee /etc/apt/sources.list.d/bazel.list
    sudo apt update && sudo apt install bazel
}

install_grpc_cli() {
    pushd "$(mktemp -d)"
    git clone https://github.com/grpc/grpc.git ./
    git submodule update --init
    make -j 6 grpc_cli
    mv ./bins/opt/grpc_cli ~/.local/bin/grpc_cli
    popd  # mktemp -d
}

install_gcloud() {
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

    # Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    # Update the package list and install the Cloud SDK
    sudo apt-get update && sudo apt-get install google-cloud-sdk
}

install_clangd() {
    sudo apt install clangd-10
}

install_tools() {
    install_tmux
    install_neovim
    install_vim_plugged
    install_powerline_status
    install_docker
    install_bazel
    # install_grpc_cli
    # install_gcloud
    install_clangd
}

install() {
    sudo apt update && sudo apt upgrade
    install_deps
    install_langs
    install_tools
    sudo apt autoremove
}

install
