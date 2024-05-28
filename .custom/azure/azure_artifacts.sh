refresh_feed_credentials() {
	ALIAS=$(az account show --query user.name -o tsv)
	ACCESS_TOKEN=$(az account get-access-token --query accessToken -o tsv)

	export POETRY_HTTP_BASIC_AZTUX_USERNAME="$ALIAS"
	export POETRY_HTTP_BASIC_AZTUX_PASSWORD="$ACCESS_TOKEN"
	export POETRY_HTTP_BASIC_AZTUX_ARTIFACTS_USERNAME="$ALIAS"
	export POETRY_HTTP_BASIC_AZTUX_ARTIFACTS_PASSWORD="$ACCESS_TOKEN"
}
