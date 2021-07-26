source $HOME/.custom/lambda-sh/lambda.sh

az_vm_create() {
    LAMBDA_ARGS_ADD \
        --name "name" \
        --description "Name of the virtual machine" \
        --default "vmarcella-$RANDOM"

    LAMBDA_ARGS_COMPILE "$@"


    if [ $# = 1 ]; then
        return
    fi

    LAMBDA_LOG_INFO "$LAMBDA_name"

    lambda_args_cleanup
}

az_vm_remove() {

}
