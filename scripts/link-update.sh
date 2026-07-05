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
	if [[ -d "$destination" && ! -L "$destination" ]]; then
		mv "$destination" "${destination}.${NOW}"
	fi
	ln --symbolic --force --no-dereference --no-target-directory -S ".${NOW}" "$source" "$destination"
}

function update_file() {
	local source="$(realpath "$1")"
	local destination="$2"

	printf "${GREEN}cp %-60s %-60s${RESET}\n" "$source" "$destination"
	mkdir -p "$(dirname "$destination")"
	cp "$source" "$destination"
}

function update_directory() {
	local source="$(realpath "$1")"
	local destination="$2"

	printf "${GREEN}cp -r %-57s %-60s${RESET}\n" "$source" "$destination"
	mkdir -p "$destination"
	cp --recursive "${source}/." "$destination"
}

function main() {
	local input
	local window_user_name=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r')

	parse_option "$@"

	read -erp "Do you want to update? [Y,n]: " input
	if [[ "$input" == "Y" ]]; then
		####################################################
		# [Linux] .bash_aliases
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../bash/.bash_aliases" \
		  "${HOME}/.bash_aliases"

		####################################################
		# [Linux] .bashrc
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../bash/.bashrc" \
		  "${HOME}/.bashrc"

		####################################################
		# [Linux] .profile
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../bash/.profile" \
		  "${HOME}/.profile"

		####################################################
		# [biome] biome.json
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../.config/biome/biome.json" \
		  "${HOME}/.config/biome/biome.json"

		####################################################
		# [EditorConfig] .editorconfig
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../.config/editorconfig/.editorconfig" \
		  "${HOME}/.editorconfig"

		####################################################
		# [git] .gitconfig
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../git/.gitconfig" \
		  "${HOME}/.gitconfig"

		####################################################
		# [git] .gitconfig.local
		####################################################
		if [ -f "${SCRIPT_DIR}/../git/.gitconfig.local" ]; then
			create_link \
			  "${SCRIPT_DIR}/../git/.gitconfig.local" \
			  "${HOME}/.gitconfig.local"
		fi

		####################################################
		# [markdownlint-cli2] .markdownlint-cli2.jsonc
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../.config/markdownlint-cli2/.markdownlint-cli2.jsonc" \
		  "${HOME}/.markdownlint-cli2.jsonc"

		####################################################
		# [mise] config.toml
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../mise/config.toml" \
		  "${HOME}/.config/mise/config.toml"

		####################################################
		# [pip] pip.conf
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../.config/pip/pip.conf" \
		  "${HOME}/.config/pip/pip.conf"

		####################################################
		# [pnpm] rc
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../.config/pnpm/rc" \
		  "${HOME}/.config/pnpm/rc"

		####################################################
		# [sqruff] .sqruff
		####################################################
		# create_link \
		#   "${SCRIPT_DIR}/../.config/sqruff/.sqruff" \
		#   "${HOME}/.sqruff"

		####################################################
		# [Skills] skill folders
		####################################################
		local skills_dir="${SCRIPT_DIR}/../skills"
		local skill_dir
		local skill_name

		for skill_dir in "$skills_dir"/*; do
			[[ -d "$skill_dir" && -f "${skill_dir}/SKILL.md" ]] || continue

			skill_name="$(basename "$skill_dir")"
			create_link "$skill_dir" "${HOME}/.agents/skills/${skill_name}"
			create_link "$skill_dir" "${HOME}/.claude/skills/${skill_name}"
		done

		####################################################
		# [uv] uv.toml
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../.config/uv/uv.toml" \
		  "${HOME}/.config/uv/uv.toml"

		####################################################
		# [VS Code] settings.json (Remote)
		####################################################
		create_link \
		  "${SCRIPT_DIR}/../vscode/settings-wsl/settings.json" \
		  "${HOME}/.vscode-server/data/Machine/settings.json"

		####################################################
		# [VS Code] settings.json (User)
		####################################################
		update_file \
		  "${SCRIPT_DIR}/../vscode/settings-windows/settings.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/settings.json"

		####################################################
		# [VS Code] tasks
		####################################################
		update_file \
		  "${SCRIPT_DIR}/../vscode/tasks.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/tasks.json"

		####################################################
		# [VS Code] key shortcut
		####################################################
		update_file \
		  "${SCRIPT_DIR}/../vscode/keybindings.json" \
		  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/keybindings.json"

		####################################################
		# [VS Code] snippet
		####################################################
		local snippets_dir="${SCRIPT_DIR}/../vscode/snippets"
		local snippet_file
		local snippet_name

		for snippet_file in "$snippets_dir"/*.json; do
			[[ -f "$snippet_file" ]] || continue

			snippet_name="$(basename "$snippet_file")"
			update_file \
			  "$snippet_file" \
			  "/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/snippets/${snippet_name}"
		done

		####################################################
		# [PowerShell] Advanced Function
		####################################################
		# ExecutionPolicy 設定
		powershell.exe -NoProfile -Command '& {
			if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
				Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
			}
		}'

		local pwsh_modules_dir="/mnt/c/Users/${window_user_name}/Documents/WindowsPowerShell/Modules"
		local pwsh_modules_dir_win="C:\\Users\\${window_user_name}\\Documents\\WindowsPowerShell\\Modules"

		# PSModulePath に module 配置先ディレクトリを追加
		# shellcheck disable=SC2016
		powershell.exe -NoProfile -Command '& {
			param([string]$ModulePath)

			$userPath = [Environment]::GetEnvironmentVariable("PSModulePath", "User")
			$paths = @($ModulePath)

			if ($userPath) {
				$paths += $userPath -split ";" | Where-Object { $_ -and $_ -ne $ModulePath }
			}

			[Environment]::SetEnvironmentVariable("PSModulePath", ($paths -join ";"), "User")
		}' "$pwsh_modules_dir_win"

		local pwshs_dir="${SCRIPT_DIR}/../pwsh/advanced-function"
		local pwsh_dir
		local pwsh_name

		for pwsh_dir in "$pwshs_dir"/*; do
			[[ -d "$pwsh_dir" ]] || continue

			pwsh_name="$(basename "$pwsh_dir")"
			update_directory \
			  "$pwsh_dir" \
			  "${pwsh_modules_dir}/${pwsh_name}"
		done
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
