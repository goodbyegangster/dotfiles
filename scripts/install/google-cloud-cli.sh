#!/usr/bin/env bash
#
# Google Cloud CLI を apt repository からインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

# Google Cloud CLI をインストールする。
install() {
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

# Google Cloud CLI のインストールを実行する。
main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
