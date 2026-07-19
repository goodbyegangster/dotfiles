#!/usr/bin/env bash
#
# Docker rootless mode をインストールし、ユーザーサービスとして有効化する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

# Docker rootless mode と必要パッケージをインストールする。
install() {
	local -a conflict_packages=(
		docker.io
		docker-compose
		docker-compose-v2
		docker-doc
		podman-docker
		containerd
		runc
	)
	local -a installed_packages

	# https://docs.docker.com/engine/security/rootless/
	if ! command -v docker &>/dev/null; then
		mapfile -t installed_packages < <(
			dpkg-query \
				--show \
				--showformat='${binary:Package}\n' \
				"${conflict_packages[@]}" 2>/dev/null || true
		)

		if [[ "${#installed_packages[@]}" -gt 0 ]]; then
			# 競合する既存パッケージを削除する。
			sudo apt-get remove -y "${installed_packages[@]}"
		fi

		# rootless Docker に必要なパッケージをインストールする。
		sudo apt-get update -y
		sudo apt-get install -y \
			uidmap \
			iptables

		# rootless Docker をインストールする。
		curl -fsSL https://get.docker.com/rootless | sh
		# Docker のユーザーサービスを有効化する。
		systemctl --user enable docker
	fi
}

# Docker rootless mode のインストールを実行する。
main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
