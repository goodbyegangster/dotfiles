#!/usr/bin/env bash
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RESET='\033[0m'

function update-apt {
	echo -e "${GREEN}Updating apt repositories...${RESET}"
	sudo apt-get update
}

# nvm
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
function install-nvm {
	local version="v0.40.3"
	if ! command -v nvm &>/dev/null; then
		echo -e "${GREEN}install nvm${RESET}"
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh | bash
	fi
}

# Deno
# https://docs.deno.com/runtime/getting_started/installation/
function install-deno {
	if ! command -v deno &>/dev/null; then
		echo -e "${GREEN}install Deno${RESET}"
		sudo apt-get install -y unzip
		curl -fsSL https://deno.land/install.sh | sh
	fi
}

# pnpm
# https://pnpm.io/ja/installation#posix-%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0%E3%81%AE%E5%A0%B4%E5%90%88
function install-pnpm {
	if ! command -v pnpm &>/dev/null; then
		echo -e "${GREEN}install pnpm${RESET}"
		curl -fsSL https://get.pnpm.io/install.sh | sh -
	fi
}

# Biome
# https://biomejs.dev/ja/guides/manual-installation/#%E5%85%AC%E9%96%8B%E3%81%95%E3%82%8C%E3%81%9F%E3%83%90%E3%82%A4%E3%83%8A%E3%83%AA%E3%82%92%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B
function install-biome {
	local version="2.3.10"
	if ! command -v biome &>/dev/null; then
		echo -e "${GREEN}install biome${RESET}"
		curl -L "https://github.com/biomejs/biome/releases/download/@biomejs/biome@${version}/biome-linux-x64" -o biome
		sudo mv biome /usr/local/bin/biome
		chmod +x /usr/local/bin/biome
	fi
}

# Rootless Docker
# https://docs.docker.com/engine/security/rootless/
function install-rootless-docker {
	if ! command -v docker &>/dev/null; then
		echo -e "${GREEN}install Rootless Docker${RESET}"
		sudo apt-get remove "$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)"
		sudo apt-get install -y \
		  uidmap \
		  iptables
		curl -fsSL https://get.docker.com/rootless | sh
		systemctl --user enable docker
	fi
}

function main {
	update-apt
	install-nvm
	install-deno
	# install-pnpm
	# install-biome
	install-rootless-docker
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
