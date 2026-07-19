#!/usr/bin/env bash
#
# Snowflake CLI を deb パッケージからインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

VERSION=""

# インストールする Snowflake CLI のバージョンを入力する。
get_user_input() {
	echo "Release:"
	echo "  https://sfc-repo.snowflakecomputing.com/snowflake-cli/linux_x86_64/"
	echo "  index.html"
	read -erp "please input version(X.X.X): " VERSION
}

# Snowflake CLI をインストールする。
install() {
	local deb_file="snowflake-cli-${VERSION}.x86_64.deb"
	local download_url

	# https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation
	pushd "${HOME}" >/dev/null

	download_url="https://sfc-repo.snowflakecomputing.com/snowflake-cli/linux_x86_64"
	download_url="${download_url}/${VERSION}/${deb_file}"

	wget "$download_url"
	# Snowflake CLI の deb パッケージをインストールする。
	sudo dpkg -i "${HOME}/${deb_file}"
	# ダウンロードした deb パッケージを削除する。
	rm "${HOME}/${deb_file}"
	popd >/dev/null
}

# Snowflake CLI のバージョンを入力してインストールを実行する。
main() {
	get_user_input
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
