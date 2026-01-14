#!/usr/bin/env bash
set -Eeuo pipefail

function install() {
	# https://docs.docker.com/engine/security/rootless/
	if ! command -v docker &>/dev/null; then
		sudo apt-get remove "$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)"
		sudo apt-get install -y \
		  uidmap \
		  iptables
		curl -fsSL https://get.docker.com/rootless | sh
		systemctl --user enable docker
	fi
}

function main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
