source $HOME/.custom/lambda-sh/lambda.sh

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

az_vm_create() {
    trap "lambda_args_cleanup" EXIT ERR SIGINT RETURN

    lambda_args_add \
        --name "name" \
        --description "Name of the virtual machine" \
        --default "vmarcella-$RANDOM"

    lambda_args_add \
        --name "resource-group" \
        --description "The resource group to deploy to" \
        --default "vmarcella-rg"

    lambda_args_add \
        --name "username" \
        --description "The admin username to use" \
        --default "azlinux"

    lambda_args_compile "$@"

    if [ $? = 1 ]; then
        return
    fi

    # Add custom sizes and other configurations
    az vm create \
        -g "$LAMBDA_resource_group" \
        -n "$LAMBDA_name" \
        --admin-username "$LAMBDA_username" \
        --size "Standard_D2S_V3" \
        --image "Canonical:UbuntuServer:18.04-LTS:latest"
    lambda_assert_last_command_ok "Failed to create a virtual machine."
}
