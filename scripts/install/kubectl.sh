#!/usr/bin/env bash
set -Eeuo pipefail

function get_user_input() {
	read -erp "please input version(vX.X.X): " version
}

function main() {
	# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux
	cd "${HOME}"
	curl -LO "https://dl.k8s.io/release/${version}/bin/linux/$(uname -m)/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	get_user_input
	main
fi
