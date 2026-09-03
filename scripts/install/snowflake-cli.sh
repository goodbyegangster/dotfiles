#!/usr/bin/env bash
#
# Snowflake CLI を deb パッケージ(Linux)または pkg パッケージ(macOS)からインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

VERSION=""

# インストールする Snowflake CLI のバージョンを入力する。
get_user_input() {
	echo "Release:"
	echo "  https://sfc-repo.snowflakecomputing.com/snowflake-cli/index.html"
	read -erp "please input version(X.X.X): " VERSION
}

# Snowflake CLI を deb パッケージからインストールする(Linux)。
install_linux() {
	local deb_file="snowflake-cli-${VERSION}.x86_64.deb"
	local download_url="https://sfc-repo.snowflakecomputing.com/snowflake-cli/linux_x86_64/${VERSION}/${deb_file}"

	wget "$download_url"
	# Snowflake CLI の deb パッケージをインストールする。
	sudo dpkg -i "${HOME}/${deb_file}"
	# ダウンロードした deb パッケージを削除する。
	rm "${HOME}/${deb_file}"
}

# Snowflake CLI を pkg パッケージからインストールする(macOS)。
install_macos() {
	local arch
	local platform_dir
	local pkg_file
	local download_url

	arch="$(uname -m)"
	case "$arch" in
		arm64) platform_dir="darwin_arm64" ;;
		x86_64) platform_dir="darwin_x86_64" ;;
		*)
			echo "unsupported architecture: ${arch}" >&2
			exit 1
			;;
	esac

	pkg_file="snowflake-cli-${VERSION}-darwin-${platform_dir#darwin_}.pkg"
	download_url="https://sfc-repo.snowflakecomputing.com/snowflake-cli/${platform_dir}/${VERSION}/${pkg_file}"

	curl -fsSLO "$download_url"
	# Snowflake CLI の pkg パッケージをインストールする。
	sudo installer -pkg "${HOME}/${pkg_file}" -target /
	# ダウンロードした pkg パッケージを削除する。
	rm "${HOME}/${pkg_file}"
}

# Snowflake CLI をインストールする。
install() {
	# https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation
	pushd "${HOME}" >/dev/null

	case "$(uname -s)" in
		Linux) install_linux ;;
		Darwin) install_macos ;;
		*)
			echo "unsupported platform: $(uname -s)" >&2
			popd >/dev/null
			exit 1
			;;
	esac

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
