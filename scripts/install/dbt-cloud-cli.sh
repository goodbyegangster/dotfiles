#!/usr/bin/env bash
set -Eeuo pipefail

VERSION=""

function get_user_input() {
	read -erp "please input version(X.X.X): " VERSION
}

function install() {
	cd "${HOME}"
	wget "https://github.com/dbt-labs/dbt-cli/releases/download/v${VERSION}/dbt_${VERSION}_linux_amd64.tar.gz"
	tar -xf "${HOME}/dbt_${VERSION}_linux_amd64.tar.gz" -C ~/bin/
}

function main() {
	get_user_input
	main
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi
