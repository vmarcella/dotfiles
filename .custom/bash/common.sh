source "$HOME/.custom/bash/aliases.sh"
source "$HOME/.custom/azure/vm.sh"

DISTRIBUTION="$(cat /etc/os-release | grep ^ID= | cut -d= -f2)"

if [[ "$DISTRIBUTION" == "ubuntu" ]]; then
    source "$HOME/.custom/ubuntu/apt.sh"
fi
