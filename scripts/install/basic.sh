#!/usr/bin/env bash
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RESET='\033[0m'

function update-apt {
	echo -e "${GREEN}Updating apt repositories...${RESET}"
	sudo apt-get update
}

# jq
# https://jqlang.github.io/jq/download/
function install-jq {
	if ! command -v jq &>/dev/null; then
		echo -e "${GREEN}install jq${RESET}"
		sudo apt-get install -y jq
	fi
}

# yq(mikefarah)
# https://github.com/mikefarah/yq?tab=readme-ov-file#install
function install-yq {
	if ! command -v yq &>/dev/null; then
		echo -e "${GREEN}install yq${RESET}"
		if command -v snap &>/dev/null; then
			sudo snap install yq
        else
			sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && \
    		  chmod +x /usr/local/bin/yq
        fi
	fi
}

# direnv
# https://github.com/direnv/direnv/blob/master/docs/installation.md
function install-direnv {
	if ! command -v direnv &>/dev/null; then
		echo -e "${GREEN}install direnv${RESET}"
		curl -sfL https://direnv.net/install.sh | bash
	fi
}

# pipx
# https://github.com/pypa/pipx?tab=readme-ov-file#on-linux
function install-pipx {
	if ! command -v pipx &>/dev/null; then
		echo -e "${GREEN}install pipx${RESET}"
		sudo apt-get install -y pipx
		pipx ensurepath
	fi
}

# uv
# https://github.com/astral-sh/uv?tab=readme-ov-file#installation
function install-uv {
	if ! command -v uv &>/dev/null; then
		echo -e "${GREEN}install uv${RESET}"
		curl -LsSf https://astral.sh/uv/install.sh | sh
	fi
}

# nvm
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
function install-nvm {
	local version="v0.40.3"
	if ! command -v pre-commit &>/dev/null; then
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

# Go
# https://go.dev/doc/install
function install-go {
	local version="1.25.5"
	local tarball="go${version}.linux-amd64.tar.gz"
	if ! command -v go &>/dev/null; then
		echo -e "${GREEN}install Go${RESET}"
		curl -OL "https://go.dev/dl/${tarball}"
		sudo rm -rf /usr/local/go
		sudo tar -C /usr/local -xzf "$tarball"
		rm "$tarball"
	fi
}

# pre-commit
# https://pre-commit.com/#installation
function install-pre-commit {
	if ! command -v pre-commit &>/dev/null; then
		echo -e "${GREEN}install pre-commit${RESET}"
		pipx install pre-commit
	fi
}

# sqlfluff
# https://docs.sqlfluff.com/en/stable/gettingstarted.html#installing-sqlfluff
function install-sqlfluff {
	if ! command -v sqlfluff &>/dev/null; then
		echo -e "${GREEN}install sqlfluff${RESET}"
		pipx install sqlfluff
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

# hadolint
# https://github.com/hadolint/hadolint?tab=readme-ov-file#install
function install-hadolint {
	local version="2.14.0"
	local file="hadolint-linux-x86_64"
	if ! command -v hadolint &>/dev/null; then
		echo -e "${GREEN}install hadolint${RESET}"
		curl -OL "https://github.com/hadolint/hadolint/releases/download/v${version}/${file}"
		chmod +x "${file}"
		sudo mv "${file}" "/usr/local/bin/hadolint"
	fi
}

function main {
	update-apt
	# install-jq
	# install-yq
	# install-direnv
	install-pipx
	install-uv
	install-nvm
	install-deno
	install-pnpm
	install-biome
	install-go
	install-pre-commit
	install-sqlfluff
	install-rootless-docker
	# install-hadolint
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
