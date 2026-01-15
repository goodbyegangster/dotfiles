#!/usr/bin/env bash
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RESET='\033[0m'

function update-apt {
	echo -e "${GREEN}Updating apt repositories...${RESET}"
	sudo apt-get update
}

# nvm
# rm -rf $NVM_DIR
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
function install-nvm {
	local version="v0.40.3"
	if ! command -v nvm &>/dev/null; then
		echo -e "${GREEN}install nvm${RESET}"
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh | bash
	fi
}

function main {
	update-apt
	# install-nvm
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
