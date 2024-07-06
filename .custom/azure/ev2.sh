install_ev2() {
  echo "Fetching ev2 repository..."

  mkdir -p "$HOME/dev/azure"

  pushd "$HOME/dev/azure"

  git clone https://msazure.visualstudio.com/DefaultCollection/One/_git/Azure-Express-Cli

  pushd Azure-Express-Cli

  # Update source and build the ev2 binary.
  git pull origin master
  go mod vendor
  go build -o linux/ev2 ev2

  # Copy the ev2 binary and configurations to my home directory
  mkdir -p "$HOME/.ev2"
  cp -r linux/ev2 "$HOME/.ev2"
  cp -r ev2cli_release.yaml configurations "$HOME/.ev2"
  sudo ln -sf "$HOME/.ev2/ev2" /usr/local/bin/ev2

  popd # $HOME/dev/azureJ
  popd # Azure-Express-Cli

  if [[ "$SHELL" == *"bash"* ]]; then
    mkdir -p "$HOME/.bash/completions"
    ev2 tabcompletion --shell bash >"$HOME/.bash/completions/_ev2"
  elif [[ "$SHELL" == *"zsh"* ]]; then
    mkdir -p "$HOME/.zsh/completions"
    ev2 tabcompletion --shell zsh >"$HOME/.zsh/completions/_ev2"
  fi

  echo "ev2 and it's completions have been installed."
}
