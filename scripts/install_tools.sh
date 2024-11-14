#!/usr/bin/bash
set -Eeuo pipefail

GREEN='\033[0;32m'
RESET='\033[0m'

function install_jq {
	if ! command -v jq &>/dev/null; then
		echo -e "${GREEN}install jq${RESET}"
		# https://jqlang.github.io/jq/download/
		sudo apt-get install jq
	fi
}

function install_yq {
	if ! command -v yq &>/dev/null; then
		echo -e "${GREEN}install yq${RESET}"
		# https://github.com/mikefarah/yq?tab=readme-ov-file#install
		sudo snap install yq
	fi
}

function install_pyenv {
	if ! command -v pyenv &>/dev/null; then
		echo -e "${GREEN}install pyenv${RESET}"
		# https://github.com/pyenv/pyenv?tab=readme-ov-file#automatic-installer
		curl https://pyenv.run | bash
		# https://github.com/pyenv/pyenv/wiki/Common-build-problems#prerequisites
		sudo apt install libedit-dev
		sudo apt install libncurses5-dev
		# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
		sudo apt update
		sudo apt install build-essential libssl-dev zlib1g-dev \
			libbz2-dev libreadline-dev libsqlite3-dev curl git \
			libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	fi
}

function install_pipx {
	if ! command -v pipx &>/dev/null; then
		echo -e "${GREEN}install pipx${RESET}"
		# https://github.com/pypa/pipx?tab=readme-ov-file#on-linux
		sudo apt update
		sudo apt install pipx
		pipx ensurepath
	fi
}

function install_poetry {
	if ! command -v poetry &>/dev/null; then
		echo -e "${GREEN}install poetry${RESET}"
		# https://python-poetry.org/docs/#installation
		pipx install poetry
		poetry config virtualenvs.in-project true
		# shellcheck disable=SC1083
		poetry config virtualenvs.prompt "{project_name}"
	fi
}

function install_pre-commit {
	if ! command -v pre-commit &>/dev/null; then
		echo -e "${GREEN}install pre-commit${RESET}"
		# https://pre-commit.com/#installation
		pipx install pre-commit
	fi
}

function main {
	install_jq
	install_yq
	install_pyenv
	install_pipx
	install_poetry
	install_pre-commit
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
