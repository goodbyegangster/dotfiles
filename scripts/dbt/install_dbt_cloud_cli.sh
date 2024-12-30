#!/usr/bin/env bash
set -Eeuo pipefail

function get_user_input() {
	read -rp "please input version(X.X.X): " version
}

function main() {
	cd "${HOME}"
	wget "https://github.com/dbt-labs/dbt-cli/releases/download/v${version}/dbt_${version}_linux_amd64.tar.gz"
	tar -xf "${HOME}/dbt_${version}_linux_amd64.tar.gz" -C ~/bin/
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	get_user_input
	main
fi
