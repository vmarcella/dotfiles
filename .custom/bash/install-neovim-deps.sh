
install_lsp() {
  # bashls
  npm i -g bash-language-server

  # bicep
   
  # Fetch the latest Bicep CLI binary
  curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
  #
  # Mark it as executable
  chmod +x ./bicep
  #
  # Add bicep to your PATH (requires admin)
  sudo mv ./bicep /usr/local/bin/bicep

  # cmake
  pip install --user --upgrade cmake-language-server

  # dockerls
  npm install -g dockerfile-language-server-nodejs

  # cssls, eslint, json
  npm i -g vscode-langservers-extracted
  #
  # Rust analyzer
  rustup component add rust-src
  rustup component add rust-analyzer

  # gopls
  go install golang.org/x/tools/gopls@latest

  # pyrirght
  pip install --user --upgrade pyright

  # vimls
  npm install -g vim-language-server

  # tsserver
  npm install -g typescript-language-server

  # yamlls
  npm install -g yaml-language-server

  # marksman
  sudo snap install marksman

  # graphql
  npm install -g graphql-language-service-cli

  # docker_compose_language_service
  npm install @microsoft/compose-language-service

  # csharp_ls
  dotnet tool install --global csharp-ls


  brew install marksman
 }

install_diagnostics () {
  # actionlint
  go install github.com/rhysd/actionlint/cmd/actionlint@latest

  # Buf
  npm install -g @bufbuild/buf

  # checkmake
  go install github.com/mrtazz/checkmake/cmd/checkmake@latest

  # cmake lint
  pip install --user cmakelang
 
  # cpplint
  pip install --user cpplint

  # Install deno for deno_lint
  curl -fsSL https://deno.land/x/install/install.sh | sh
 
  # dotenv_linter
  curl -sSfL \
    https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s

  # flake8
  pip install --user flake8

  # Markdownlint
  npm install -g markdownlint

  # Install ruff & pylint
  pip install --user ruff pylint[spelling]

  # Install staticcheck
  go install honnef.co/go/tools/cmd/staticcheck@latest

  # tfsec
  curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

  # install typescript
  npm install -g typescript

  # yamllint
  pip install --user yamllint

}

install_formatters () {
  #  # Install autoflake
  pip install --user --upgrade autoflake 

  # Install autopep8
  pip install --user --upgrade autopep8

  # Install black
  pip install black

  # cbformat
  cargo install cbfmt

  # csharpier
  dotnet tool install csharpier -g

  #fixjson
  npm install -g fixjson

  # goimports
  go install golang.org/x/tools/cmd/goimports@latest

  # isort 
  pip install --user isort

  # shellharden
  cargo install shellharden

  # shfmt
  go install mvdan.cc/sh/v3/cmd/shfmt@latest

  # sqlfluff
  pip install sqlfluff

  # sql-formatter
  npm install -g sql-formatter

  # terrafmt
  go install github.com/katbyte/terrafmt@latest

  # terraform & terraform-ls
  sudo apt update && sudo apt install terraform terraform-ls

  # textlint
  npm install -g textlint 

  # yamlfmt
  go install github.com/google/yamlfmt/cmd/yamlfmt@latest



}

install_neovim_dependencies() {
  install_lsp
  install_diagnostics
  install_formatters
}
