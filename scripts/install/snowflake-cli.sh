#!/usr/bin/env bash
set -Eeuo pipefail

VERSION=""

function get_user_input() {
	echo "Release: https://sfc-repo.snowflakecomputing.com/snowflake-cli/linux_x86_64/index.html"
	read -erp "please input version(X.X.X): " VERSION
}

function install() {
	# https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation/installation#install-with-linux-package-managers
	pushd "${HOME}" > /dev/null
	wget "https://sfc-repo.snowflakecomputing.com/snowflake-cli/linux_x86_64/${VERSION}/snowflake-cli-${VERSION}.x86_64.deb"
	sudo dpkg -i "${HOME}/snowflake-cli-${VERSION}.x86_64.deb"
	rm "${HOME}/snowflake-cli-${VERSION}.x86_64.deb"
	popd > /dev/null
}

function main() {
	get_user_input
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
