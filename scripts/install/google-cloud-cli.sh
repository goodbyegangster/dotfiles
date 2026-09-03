#!/usr/bin/env bash
#
# Google Cloud CLI を Linux では apt repository、macOS では tarball からインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

# Google Cloud CLI を tarball からインストールする(macOS)。
install_macos() {
	local arch
	local archive_file
	local download_url

	# https://docs.cloud.google.com/sdk/docs/install-sdk?hl=ja#mac
	case "$(uname -m)" in
		x86_64) arch="x86_64" ;;
		arm64) arch="arm" ;;
		*)
			echo "unsupported architecture: $(uname -m)" >&2
			exit 1
			;;
	esac

	archive_file="google-cloud-cli-darwin-${arch}.tar.gz"
	download_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${archive_file}"

	pushd "${HOME}" >/dev/null

	curl -fsSLO "$download_url"
	# Google Cloud CLI の tarball を展開する。
	tar -xf "${HOME}/${archive_file}"
	rm "${HOME}/${archive_file}"

	# Google Cloud CLI をインストールする(非対話モード)。
	"${HOME}/google-cloud-sdk/install.sh" --quiet

	popd >/dev/null
}

# Google Cloud CLI を apt repository からインストールする(Linux)。
install_linux() {
	local apt_source

	# https://docs.cloud.google.com/sdk/docs/install-sdk?hl=ja#deb
	if ! command -v gcloud &>/dev/null; then
		# Google Cloud CLI のインストールに必要なパッケージを追加する。
		sudo apt-get update -y
		sudo apt-get install -y \
			apt-transport-https \
			ca-certificates \
			gnupg \
			curl

		# Google Cloud CLI の apt keyring を追加する。
		curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
			| sudo gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg

		apt_source="deb [signed-by=/usr/share/keyrings/cloud.google.gpg]"
		apt_source="${apt_source} https://packages.cloud.google.com/apt"
		apt_source="${apt_source} cloud-sdk main"
		# Google Cloud CLI の apt repository を追加する。
		echo "$apt_source" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

		# Google Cloud CLI をインストールする。
		sudo apt-get update -y
		sudo apt-get install -y google-cloud-cli
	fi
}

# Google Cloud CLI を最新バージョンへ upgrade する(macOS)。
upgrade_macos() {
	gcloud components update --quiet
}

# Google Cloud CLI を最新バージョンへ upgrade する(Linux)。
upgrade_linux() {
	sudo apt-get update -y
	sudo apt-get install -y --only-upgrade google-cloud-cli
}

# Google Cloud CLI のインストールを実行する。
main() {
	case "$(uname -s)" in
		Linux)
			install_linux
			upgrade_linux
			;;
		Darwin)
			install_macos
			upgrade_macos
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
