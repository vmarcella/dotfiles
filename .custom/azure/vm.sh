source $HOME/.custom/lambda-sh/lambda.sh

az_vm_create() {
    lambda_args_add \
        --name "name" \
        --description "Name of the virtual machine" \
        --default "vmarcella-$RANDOM"

    lambda_args_compile "$@"

    if [ $# = 1 ]; then
        return
    fi

    lambda_log_info "$LAMBDA_name"

    lambda_args_cleanup
}
