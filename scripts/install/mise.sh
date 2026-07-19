#!/usr/bin/env bash
#
# mise を apt repository からインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

# mise をインストールする。
install_mise() {
	local apt_source

	# https://mise.jdx.dev/installing-mise.html#apt
	if ! command -v mise &>/dev/null; then
		# mise のインストールに必要なパッケージを追加する。
		sudo apt-get update -y
		sudo apt-get install -y curl

		# mise の apt keyring を追加する。
		sudo install -dm 755 /etc/apt/keyrings
		curl -fSs https://mise.jdx.dev/gpg-key.pub \
			| sudo tee /etc/apt/keyrings/mise-archive-keyring.pub 1>/dev/null

		apt_source="deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.pub"
		apt_source="${apt_source} arch=amd64] https://mise.jdx.dev/deb stable main"
		# mise の apt repository を追加する。
		echo "$apt_source" | sudo tee /etc/apt/sources.list.d/mise.list

		# mise をインストールする。
		sudo apt-get update -y
		sudo apt-get install -y mise
	fi
}

# mise のインストールを実行する。
main() {
	install_mise
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
