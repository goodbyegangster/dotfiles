#!/usr/bin/env bash
#
# Google Chrome を deb パッケージからインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

CHROME_TMPDIR=""

# 一時ディレクトリを削除する。
cleanup() {
	if [[ -n "$CHROME_TMPDIR" ]]; then
		# ダウンロード用の一時ディレクトリを削除する。
		rm -rf "$CHROME_TMPDIR"
	fi
}

# Google Chrome をインストールする。
install() {
	if ! command -v google-chrome &>/dev/null; then
		CHROME_TMPDIR=$(mktemp -d)
		chmod 755 "$CHROME_TMPDIR"
		trap cleanup EXIT

		# Google Chrome の deb パッケージをダウンロードする。
		curl -fsSLo "${CHROME_TMPDIR}/google-chrome-stable_current_amd64.deb" \
			https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		chmod 644 "${CHROME_TMPDIR}/google-chrome-stable_current_amd64.deb"

		# Google Chrome の deb パッケージをインストールする。
		sudo apt update
		sudo apt install -y "${CHROME_TMPDIR}/google-chrome-stable_current_amd64.deb"
	fi
}

# Google Chrome のインストールを実行する。
main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
