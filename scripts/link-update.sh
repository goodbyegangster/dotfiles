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
		case ${1:-} in
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

	printf "${GREEN}ln -s %-60s %-60s${RESET}\n" "$source" "$destination"
	mkdir -p "$(dirname "$destination")"
	ln --symbolic --force -S ".${NOW}" "$source" "$destination"
}

function update_file() {
	local source="$(realpath "$1")"
	local destination="$2"

	printf "${GREEN}cp %-60s %-60s${RESET}\n" "$source" "$destination"
	mkdir -p "$(dirname "$destination")"
	cp "$source" "$destination"
}

function main() {
	local input
	local window_user_name=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r')

	parse_option "$@"

	read -erp "Do you want to update? [Y,n]: " input
	if [[ "$input" == "Y" ]]; then
		# [Linux] .bash_aliases
		create_link \
		  "${SCRIPT_DIR}/../bash/.bash_aliases" \
		  "${HOME}/.bash_aliases"
		# [Linux] .bashrc
		create_link \
		  "${SCRIPT_DIR}/../bash/.bashrc" \
		  "${HOME}/.bashrc"
		# [Linux] .profile
		create_link \
		  "${SCRIPT_DIR}/../bash/.profile" \
		  "${HOME}/.profile"

		# [mise] config.toml
		create_link \
		  "${SCRIPT_DIR}/../mise/config.toml" \
		  "${HOME}/.config/mise/config.toml"

		# [git] .gitconfig
		create_link \
		  "${SCRIPT_DIR}/../git/.gitconfig" \
		  "${HOME}/.gitconfig"
		# [git] .gitmessage.txt
		create_link \
		  "${SCRIPT_DIR}/../git/.gitmessage.txt" \
		  "${HOME}/.gitmessage.txt"

		# [pnpm] rc
		create_link \
		  "${SCRIPT_DIR}/../.config/pnpm/rc" \
		  "${HOME}/.config/pnpm/rc"

		# [VS Code] settings.json (Remote)
		create_link \
		  "${SCRIPT_DIR}/../vscode/settings-wsl/settings.json" \
		  "${HOME}/.vscode-server/data/Machine/settings.json"
		# [VS Code] settings.json (User)
		update_file \
		  "${SCRIPT_DIR}/../vscode/settings-windows/settings.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/settings.json"
		# [VS Code] key shortcut
		update_file \
		  "${SCRIPT_DIR}/../vscode/keybindings.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/keybindings.json"
		# [VS Code] snippet
		update_file \
		  "${SCRIPT_DIR}/../vscode/snippets/makefile.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/snippets/makefile.json"
		update_file \
		  "${SCRIPT_DIR}/../vscode/snippets/shellscript.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/snippets/shellscript.json"
		update_file \
		  "${SCRIPT_DIR}/../vscode/snippets/typescript.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/snippets/typescript.json"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
