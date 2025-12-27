#!/usr/bin/env bash
# shellcheck disable=SC2155
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;32m'
readonly RESET='\033[0m'

readonly NOW=$(date "+%Y%m%d%H%M%S")

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
	printf "ln -s %-60s %-60s\n" "$1" "$2"
	mkdir -p "$(dirname "$2")"
	ln --symbolic --force -S ".${NOW}" "$1" "$2"
}

function update_links() {
	local input

	read -erp "Do you want to update symbolic links? [Y,n]: " input
	if [ "$input" == "Y" ]; then
		echo -e "${GREEN}Create symbolic links${RESET}"
		create_link "$HOME/dotfiles/dotfiles/bash/.bash_aliases" "$HOME/.bash_aliases"
		create_link "$HOME/dotfiles/dotfiles/bash/.profile" "$HOME/.profile"
		create_link "$HOME/dotfiles/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
		create_link "$HOME/dotfiles/dotfiles/git/.gitmessage.txt" "$HOME/.gitmessage.txt"
		create_link "$HOME/dotfiles/dotfiles/vscode/settings.json" "$HOME/.vscode-server/data/Machine/settings.json"
	fi
}

function update_snippets() {
	local input
	local default_user

	read -erp "Do you want to update snippets? [Y,n]: " input
	if [ "$input" == "Y" ]; then
	    default_user=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r')
		read -erp "Please enter your Windows OS user name [${default_user}]: " username
		echo -e "${GREEN}Copy snippets file${RESET}"
		cp ./dotfiles/vscode/snippets/typescript.json \
		  "/mnt/c/Users/${username:-$default_user}/AppData/Roaming/Code/User/snippets/typescript.json"
	fi
}

function update_keybindings() {
	local input
	local default_user

	read -erp "Do you want to update keybindings? [Y,n]: " input
	if [ "$input" == "Y" ]; then
	    default_user=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r')
		read -erp "Please enter your Windows OS user name [${default_user}]: " username
		echo -e "${GREEN}Copy keybindings file${RESET}"
		cp ./dotfiles/vscode/keybindings.json \
		  "/mnt/c/Users/${username:-$default_user}/AppData/Roaming/Code/User/keybindings.json"
	fi
}

function main() {
	parse_option "$@"

	update_links
	update_snippets
	update_keybindings
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
