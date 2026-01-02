#!/usr/bin/env bash
# shellcheck disable=SC2155
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;32m'
readonly RESET='\033[0m'

readonly NOW=$(date "+%Y%m%d%H%M%S")
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function usage() {
	cat <<-EOF
		Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

		Create symbolic links for dotfiles.

		Options:
		-h, --help     Print this help
		-v, --verbose  Print script debug info
	EOF
}

function parse_option() {
	while :; do
		case ${1:-default} in
		-h | --help) usage && exit ;;
		-v | --verbose) set -x ;;
		-?*)
			printf "${RED}%s${RESET}\n" "ERROR: unknown option" >&2
			usage && exit 1
			;;
		*) break ;;
		esac
		shift
	done
}

function create_link() {
	local source="$(realpath "$1")"
	local destination="$2"

	printf "ln -s %-60s %-60s\n" "$source" "$destination"
	mkdir -p "$(dirname "$destination")"
	ln --symbolic --force -S ".${NOW}" "$source" "$destination"
}

function update_file() {
	local source="$(realpath "$1")"
	local destination="$2"

	printf "cp %-60s %-60s\n" "$source" "$destination"
	mkdir -p "$(dirname "$destination")"
	cp "$source" "$destination"
}

function main() {
	local input
	local window_user_name=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r')

	parse_option "$@"

	read -erp "Do you want to update? [Y,n]: " input
	if [[ "$input" == "Y" ]]; then
		echo -e "${GREEN}Create symbolic links${RESET}"
		create_link \
		  "${SCRIPT_DIR}/../dotfiles/bash/.bash_aliases" \
		  "${HOME}/.bash_aliases"
		create_link \
		  "${SCRIPT_DIR}/../dotfiles/bash/.profile" \
		  "${HOME}/.profile"
		create_link \
		  "${SCRIPT_DIR}/../dotfiles/git/.gitconfig" \
		  "${HOME}/.gitconfig"
		create_link \
		  "${SCRIPT_DIR}/../dotfiles/git/.gitmessage.txt" \
		  "${HOME}/.gitmessage.txt"
		create_link \
		  "${SCRIPT_DIR}/../dotfiles/vscode/settings-wsl/settings.json" \
		  "${HOME}/.vscode-server/data/Machine/settings.json"

		echo -e "${GREEN}Update file${RESET}"
		update_file \
		  "${SCRIPT_DIR}/../dotfiles/vscode/settings-windows/settings.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/settings.json"
		update_file \
		  "${SCRIPT_DIR}/../dotfiles/vscode/keybindings.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/keybindings.json"
		update_file \
		  "${SCRIPT_DIR}/../dotfiles/vscode/snippets/shellscript.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/snippets/shellscript.json"
		update_file \
		  "${SCRIPT_DIR}/../dotfiles/vscode/snippets/typescript.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/snippets/typescript.json"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
