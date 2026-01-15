#!/usr/bin/env bash
set -Eeuo pipefail

function install() {
	# https://docs.cloud.google.com/sdk/docs/install-sdk?hl=ja#deb
	if ! command -v gcloud &>/dev/null; then
		sudo apt-get update -y
		sudo apt-get install -y \
		  apt-transport-https \
		  ca-certificates \
		  gnupg \
		  curl

		curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
		  sudo gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg

		echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
		  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

		sudo apt-get update -y
		sudo apt-get install -y google-cloud-cli
	fi
}

function main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
