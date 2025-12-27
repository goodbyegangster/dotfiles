#!/usr/bin/env bash
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RESET='\033[0m'

function remove_links() {
	local -a files
	local file

	local target_dir=$1

	mapfile -t files < <(find "$target_dir" -maxdepth 1 -type l -regextype sed -regex ".*[0-9]\{14\}$" | sort)
	for file in "${files[@]}"; do
		echo "rm ${file}"
		rm "$file"
	done
}

function main() {
	echo -e "${GREEN}Remove symbolic links${RESET}"

	remove_links "$HOME"
	remove_links "$HOME/.vscode-server/data/Machine"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
