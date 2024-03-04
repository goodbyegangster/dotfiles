#!/usr/bin/env bash
set -Eeuo pipefail

NOW=$(date "+%Y%m%d%H%M%S")
readonly NOW

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
			printf "\033[31m%s\033[m\n\n" "ERROR: unknown option" >&2
			usage && exit 1
			;;
		*) break ;;
		esac
		shift
	done
}

function create_link() {
	printf "ln -s %-60s %-60s\n" "$1" "$2"
	ln --symbolic --force -S ".$NOW" "$1" "$2"
}

function main() {
	parse_option "$@"

	printf "\033[32m%s\033[m\n" "### Create symbolic links: start ####"
	create_link "$HOME/dotfiles/dotfiles/bash/.bashrc" "$HOME/.bashrc"
	create_link "$HOME/dotfiles/dotfiles/bash/.profile" "$HOME/.profile"
	create_link "$HOME/dotfiles/dotfiles/vscode-server/settings.json" "$HOME/.vscode-server/data/Machine/settings.json"
	create_link "$HOME/dotfiles/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
	printf "\033[32m%s\033[m\n" "### Create symbolic links: end   ####"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
