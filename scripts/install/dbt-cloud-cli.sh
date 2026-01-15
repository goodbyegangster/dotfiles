#!/usr/bin/env bash
set -Eeuo pipefail

VERSION=""

function get_user_input() {
	echo "Release: https://github.com/dbt-labs/dbt-cli/releases"
	read -erp "please input version(X.X.X): " VERSION
}

function install() {
	# https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=linux
	cd "${HOME}"
	wget "https://github.com/dbt-labs/dbt-cli/releases/download/v${VERSION}/dbt_${VERSION}_linux_amd64.tar.gz"
	sudo tar -xf "${HOME}/dbt_${VERSION}_linux_amd64.tar.gz" -C /usr/local/bin/
	rm "${HOME}/dbt_${VERSION}_linux_amd64.tar.gz"
}

function main() {
	get_user_input
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi
