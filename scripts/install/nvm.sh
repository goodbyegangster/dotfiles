#!/usr/bin/env bash
set -Eeuo pipefail

function install() {
	# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
	local version="v0.40.3"
	if ! command -v nvm &>/dev/null; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh | bash
	fi
}

function main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
