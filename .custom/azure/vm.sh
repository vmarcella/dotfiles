source "$HOME/.custom/lambda-sh/lambda.sh"

# For helper functions to use when 
export __AZURE_VM_LAST_VM="";
export __AZURE_VM_LAST_RG=""

clear_trap() {
    trap - EXIT ERR SIGINT RETURN
}

az_subscription_set() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN

    lambda_args_add \
        --name "name" \
        --description "Name of the subscription to set." \
        --default "Azure Linux Team - Dev-Test - non-ExpressRoute"

    lambda_args_compile "$@"

    if [ $? = 1 ]; then
        return
    fi

    lambda_log_info "Setting account subscription to: $LAMBDA_name"
    az account set --subscription "$LAMBDA_name"
}

az_storage_account_create() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN
    
    lambda_args_add \
        --name name \
        --description "The name of the storage account (Same as resource group name)" \
        --default "vmarcella-rg"

    lambda_args_compile "$@"
}

az_vm_create() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN

    lambda_args_add \
        --name "name" \
        --description "Name of the virtual machine" \
        --default "vmarcella-$RANDOM"

    lambda_args_add \
        --name "resource-group" \
        --description "The resource group to deploy to." \
        --default "vmarcella-rg"

    lambda_args_add \
        --name "username" \
        --description "The admin username for the vm." \
        --default "azlinux"

    lambda_args_add \
        --name "image" \
        --description "Image to deploy on the virtual machine." \
        --default "Canonical:UbuntuServer:18.04-LTS:latest"

    lambda_args_add \
        --name "size" \
        --description "Virtual machine size." \
        --default "Standard_D2S_V3"

    lambda_args_add \
        --name "ssh-key-name" \
        --description "The name of the SSH key to use" \
        --default "~/.ssh/azlinux.pub"

    lambda_args_compile "$@"

    if [ $? = 1 ]; then
        return
    fi

    lambda_log_info "$LAMBDA_ssh_key_name"
    # Add custom sizes and other configurations
    az vm create \
        -g "$LAMBDA_resource_group" \
        -n "$LAMBDA_name" \
        --admin-username "$LAMBDA_username" \
        --size "$LAMBDA_size" \
        --image  "$LAMBDA_image" \
        --public-ip-address-dns-name "$LAMBDA_name" \
        --generate-ssh-keys

    lambda_assert_last_command_ok "Failed to create a virtual machine."

    __AZURE_VM_LAST_VM="$LAMBDA_name"
    __AZURE_VM_LAST_RG="$LAMBDA_resource_group"
}

# Create an Ubuntu Bionic virtual machine.
az_vm_create_ubuntu_bionic() {
    az_vm_create "$@" --image "Canonical:UbuntuServer:18.04-LTS:latest"
}

# Create an Ubuntu focal virtual machine.
az_vm_create_ubuntu_focal() {
    az_vm_create \
        "$@" --image "Canonical:0001-com-ubuntu-server-focal:20_04-LTS:latest"
}

az_vm_get_full_dns_name() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN

    lambda_args_add \
        --name "name" \
        --description "Virtual machine trying to be connected to."

    lambda_args_add \
        --name region \
        --description "The region that the VM is being hosted in." \
        --default "westus2"

    lambda_args_compile "$@"

    printf "$LAMBDA_name.$LAMBDA_region.cloudapp.azure.com"
}

az_vm_can_connect() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN

    lambda_args_add \
        --name "name" \
        --description "Virtual machine trying to be connected to."

    lambda_args_add \
        --name resource-group \
        --description "The Resource group the virtual machine is in." \
        --default "vmarcella-rg"

    lambda_args_compile "$@"

    local REPORTED_SOURCE_ADDRESS="$(\
        az network nsg rule show \
            --resource-group "$LAMBDA_resource_group" \
            --name "default-allow-ssh" \
            --nsg-name "${LAMBDA_name}NSG" \
            --query sourceAddressPrefix \
            -o tsv)"

    local ACTUAL_SOURCE_ADDRESS="$curl -s ipinfo.io/ip"
    echo "$ACTUAL_SOURCE_ADDRESS (Public IP) -> $CURRENT_SOURCE_ADDRESS (NSG IP)"
    if [[ "$CURRENT_SOURCE_ADDRESS" != "$ACTUAL_SOURCE_ADDRESS" ]]; then
        echo "Connection not possible"
    else
        echo "Connection possible"
    fi
}

az_vm_delete() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN

    lambda_args_add \
        --name "name" \
        --description "Name of the resource to delete"

    lambda_args_add \
        --name "resource-group" \
        --description "Name of the resource group that the resource belongs to."

    lambda_args_compile "$@"

    if [ $? = 1]; then
        return
    fi
}
