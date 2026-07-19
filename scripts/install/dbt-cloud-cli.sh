#!/usr/bin/env bash
#
# dbt Cloud CLI を GitHub Releases の tarball からインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

VERSION=""

# インストールする dbt Cloud CLI のバージョンを入力する。
get_user_input() {
	echo "Release: https://github.com/dbt-labs/dbt-cli/releases"
	read -erp "please input version(X.X.X): " VERSION
}

# dbt Cloud CLI をインストールする。
install() {
	local archive_file="dbt_${VERSION}_linux_amd64.tar.gz"
	local download_url

	download_url="https://github.com/dbt-labs/dbt-cli/releases/download"
	download_url="${download_url}/v${VERSION}/${archive_file}"

	# https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=linux
	pushd "${HOME}" >/dev/null
	wget "$download_url"
	# dbt Cloud CLI を /usr/local/bin へ展開する。
	sudo tar -xf "${HOME}/${archive_file}" -C /usr/local/bin/
	# ダウンロードした tarball を削除する。
	rm "${HOME}/${archive_file}"
	popd >/dev/null
}

# dbt Cloud CLI のバージョンを入力してインストールを実行する。
main() {
	get_user_input
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
