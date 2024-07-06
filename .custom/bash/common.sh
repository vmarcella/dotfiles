# Generic helpers
source "$HOME/.custom/bash/aliases.sh"
source "$HOME/.custom/bash/julia.sh"

# Azure helpers
source "$HOME/.custom/azure/vm.sh"
source "$HOME/.custom/azure/ev2.sh"
source "$HOME/.custom/azure/azure_artifacts.sh"

DISTRIBUTION="$(cat /etc/os-release &>/dev/null | grep ^ID= | cut -d= -f2)"

if [[ "$DISTRIBUTION" == "ubuntu" ]]; then
	source "$HOME/.custom/ubuntu/apt.sh"
fi
