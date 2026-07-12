#!/usr/bin/env bash
set -Eeuo pipefail

CHROME_TMPDIR=""

function cleanup() {
	if [[ -n "$CHROME_TMPDIR" ]]; then
		rm -rf "$CHROME_TMPDIR"
	fi
}

function install() {
	if ! command -v google-chrome &>/dev/null; then
		CHROME_TMPDIR=$(mktemp -d)
		chmod 755 "$CHROME_TMPDIR"
		trap cleanup EXIT

		curl -fsSLo "${CHROME_TMPDIR}/google-chrome-stable_current_amd64.deb" \
		  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		chmod 644 "${CHROME_TMPDIR}/google-chrome-stable_current_amd64.deb"

		sudo apt update
		sudo apt install -y "${CHROME_TMPDIR}/google-chrome-stable_current_amd64.deb"
	fi
}

function main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
