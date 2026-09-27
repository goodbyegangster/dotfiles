#!/usr/bin/env bash
#
# Google MCP Toolbox for Databases を公式配布バイナリからインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -euo pipefail

VERSION=""
TOOLBOX_TMPDIR=""

# 一時ディレクトリを削除する。
cleanup() {
	if [[ -n "$TOOLBOX_TMPDIR" ]]; then
		# ダウンロード用の一時ディレクトリを削除する。
		rm -rf "$TOOLBOX_TMPDIR"
	fi
}

# インストールする MCP Toolbox のバージョンを入力する。
get_user_input() {
	echo "Release: https://github.com/googleapis/mcp-toolbox/releases"
	read -erp "please input version(X.X.X): " VERSION

	if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		echo "invalid version: $VERSION" >&2
		return 1
	fi
}

# MCP Toolbox をインストールする。
install_toolbox() {
	local arch
	local os
	local download_url
	local toolbox_file

	case "$(uname -s)" in
		Linux) os="linux" ;;
		Darwin) os="darwin" ;;
		*)
			echo "unsupported platform: $(uname -s)" >&2
			return 1
			;;
	esac

	case "$(uname -m)" in
		x86_64) arch="amd64" ;;
		arm64 | aarch64) arch="arm64" ;;
		*)
			echo "unsupported architecture: $(uname -m)" >&2
			return 1
			;;
	esac

	if [[ "$os" == "linux" && "$arch" == "arm64" ]]; then
		echo "unsupported platform and architecture: ${os}/${arch}" >&2
		return 1
	fi

	TOOLBOX_TMPDIR="$(mktemp -d)"
	trap cleanup EXIT
	toolbox_file="${TOOLBOX_TMPDIR}/toolbox"
	download_url="https://storage.googleapis.com/mcp-toolbox-for-databases"
	download_url="${download_url}/v${VERSION}/${os}/${arch}/toolbox"

	# 公式配布バイナリをダウンロードする。
	# https://github.com/googleapis/mcp-toolbox#install-toolbox
	curl --fail --location --show-error --silent \
		--output "$toolbox_file" \
		"$download_url"

	if [[ ! -s "$toolbox_file" ]]; then
		echo "downloaded file is empty: $download_url" >&2
		return 1
	fi

	# MCP Toolbox を /usr/local/bin へインストールする。
	sudo install -m 0755 "$toolbox_file" /usr/local/bin/toolbox
}

# MCP Toolbox のバージョンを入力してインストールを実行する。
main() {
	get_user_input
	install_toolbox
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
