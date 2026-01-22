#!/usr/bin/env bash
set -Eeuo pipefail

function install_mise() {
	# https://mise.jdx.dev/installing-mise.html#apt
	if ! command -v mise &>/dev/null; then
		sudo apt-get update -y
		sudo apt-get install -y curl

		sudo install -dm 755 /etc/apt/keyrings
		curl -fSs https://mise.jdx.dev/gpg-key.pub | \
		  sudo tee /etc/apt/keyrings/mise-archive-keyring.pub 1> /dev/null
		echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.pub arch=amd64] https://mise.jdx.dev/deb stable main" | \
		  sudo tee /etc/apt/sources.list.d/mise.list

		sudo apt-get update -y
		sudo apt-get install -y mise
	fi
}

function main() {
	install_mise
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
