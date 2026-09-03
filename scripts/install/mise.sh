#!/usr/bin/env bash
#
# mise を Linux では apt repository、macOS では mise.run のインストーラーからインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

# mise をインストールする(Linux)。
install_mise_linux() {
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

# mise をインストールする(macOS)。
install_mise_macos() {
	# Homebrew は公式リリースバイナリとは別にビルドされるため、
	# mise.run のインストーラーを利用する。
	# https://mise.jdx.dev/installing-mise.html#macos
	if ! command -v mise &>/dev/null; then
		curl https://mise.run | sh
	fi
}

# mise を最新バージョンへ upgrade する(Linux)。
upgrade_mise_linux() {
	sudo apt-get update -y
	sudo apt-get install -y --only-upgrade mise
}

# mise を最新バージョンへ upgrade する(macOS)。
upgrade_mise_macos() {
	local mise_bin="mise"

	if ! command -v mise &>/dev/null; then
		mise_bin="${HOME}/.local/bin/mise"
	fi

	"$mise_bin" self-update --yes
}

# mise のインストールを実行する。
main() {
	case "$(uname -s)" in
		Linux)
			install_mise_linux
			upgrade_mise_linux
			;;
		Darwin)
			install_mise_macos
			upgrade_mise_macos
			;;
		*)
			echo "unsupported platform: $(uname -s)" >&2
			exit 1
			;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
