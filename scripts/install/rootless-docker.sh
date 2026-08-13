#!/usr/bin/env bash
#
# Docker rootless mode をインストールし、ユーザーサービスとして有効化する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

readonly DOCKER_COMPOSE_VERSION="v5.4.0"

# Docker rootless mode と必要パッケージをインストールする。
install_docker() {
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

# Docker Compose CLI プラグインをユーザーディレクトリへインストールする。
install_docker_compose() {
	local architecture
	local cli_plugins_dir
	local compose_url
	local temporary_file

	if docker compose version &>/dev/null; then
		return
	fi

	case "$(uname -m)" in
		x86_64 | amd64)
			architecture="x86_64"
			;;
		aarch64 | arm64)
			architecture="aarch64"
			;;
		*)
			printf '未対応のアーキテクチャです: %s\n' "$(uname -m)" >&2
			return 1
			;;
	esac

	cli_plugins_dir="${DOCKER_CONFIG:-${HOME}/.docker}/cli-plugins"
	compose_url="https://github.com/docker/compose/releases/download/"
	compose_url+="${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${architecture}"

	mkdir -p -- "${cli_plugins_dir}"
	temporary_file="$(mktemp "${cli_plugins_dir}/docker-compose.tmp.XXXXXX")"
	trap 'rm -f -- "${temporary_file}"' RETURN

	# Docker Compose の実行ファイルをダウンロードして配置する。
	curl -fSL "${compose_url}" --output "${temporary_file}"
	chmod 0755 "${temporary_file}"
	mv -- "${temporary_file}" "${cli_plugins_dir}/docker-compose"
	trap - RETURN
}

# Docker rootless mode のインストールを実行する。
main() {
	install_docker
	install_docker_compose
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
