#!/usr/bin/env bash
#
# dotfiles のシンボリックリンク作成と Windows 側設定ファイルの更新を行う。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly RESET='\033[0m'

readonly NOW=$(date "+%Y%m%d%H%M%S")
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_DIR

# 使い方を標準出力へ表示する。
usage() {
	cat <<-EOF
		Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

		Create symbolic links for dotfiles.

		Options:
		-h, --help     Print this help
		-v, --verbose  Print script debug info
	EOF
}

# コマンドラインオプションを解析する。
parse_option() {
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

# dotfiles 配下のファイルまたはディレクトリへのシンボリックリンクを作成する。
#
# 引数
#   $1: リンク元パス
#   $2: リンク先パス
create_link() {
	local source
	local destination=$2

	source="$(realpath "$1")"

	printf "${GREEN}ln -s %-60s %-60s${RESET}\n" "$source" "$destination"
	# リンク先ディレクトリを作成する。
	mkdir -p "$(dirname "$destination")"
	if [[ -d "$destination" && ! -L "$destination" ]]; then
		# 既存ディレクトリをバックアップへ退避する。
		mv "$destination" "${destination}.${NOW}"
	fi
	# 既存パスをバックアップし、シンボリックリンクを作成する。
	ln \
		--symbolic \
		--force \
		--no-dereference \
		--no-target-directory \
		--backup=simple \
		-S ".${NOW}" \
		"$source" \
		"$destination"
}

# dotfiles 配下のファイルをコピーして更新する。
#
# 引数
#   $1: コピー元ファイル
#   $2: コピー先ファイル
update_file() {
	local source
	local destination=$2

	source="$(realpath "$1")"

	printf "${GREEN}cp %-60s %-60s${RESET}\n" "$source" "$destination"
	# コピー先ディレクトリを作成する。
	mkdir -p "$(dirname "$destination")"
	# 既存ファイルを上書きする。
	cp "$source" "$destination"
}

# dotfiles 配下のディレクトリ内容をコピーして更新する。
#
# 引数
#   $1: コピー元ディレクトリ
#   $2: コピー先ディレクトリ
update_directory() {
	local source
	local destination=$2

	source="$(realpath "$1")"

	printf "${GREEN}cp -r %-57s %-60s${RESET}\n" "$source" "$destination"
	# コピー先ディレクトリを作成する。
	mkdir -p "$destination"
	# 既存ディレクトリ内へファイルを再帰的に上書きコピーする。
	cp --recursive "${source}/." "$destination"
}

# Windows のユーザー名を取得する。
#
# 標準出力
#   Windows のユーザー名
get_windows_user_name() {
	local window_user_name

	if ! window_user_name=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r'); then
		printf "${RED}%s${RESET}\n" "ERROR: failed to get Windows user name" >&2
		return 1
	fi

	if [[ -z "$window_user_name" ]]; then
		printf "${RED}%s${RESET}\n" "ERROR: Windows user name is empty" >&2
		return 1
	fi

	printf "%s\n" "$window_user_name"
}

# dotfiles のリンク作成と設定ファイル更新を実行する。
main() {
	local input
	local window_user_name

	parse_option "$@"

	read -erp "Do you want to update? [Y,n]: " input
	if [[ "$input" == "Y" ]]; then
		window_user_name="$(get_windows_user_name)"

		####################################################
		# [Linux] .bash_aliases をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../bash/.bash_aliases" \
			"${HOME}/.bash_aliases"

		####################################################
		# [Linux] .bashrc をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../bash/.bashrc" \
			"${HOME}/.bashrc"

		####################################################
		# [Linux] .profile をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../bash/.profile" \
			"${HOME}/.profile"

		####################################################
		# [biome] biome.json をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/biome/biome.json" \
			"${HOME}/.config/biome/biome.json"

		####################################################
		# [EditorConfig] .editorconfig をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/editorconfig/.editorconfig" \
			"${HOME}/.editorconfig"

		####################################################
		# [git] .gitconfig をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../git/.gitconfig" \
			"${HOME}/.gitconfig"

		####################################################
		# [git] .gitconfig.local をリンクする
		####################################################
		if [[ -f "${SCRIPT_DIR}/../git/.gitconfig.local" ]]; then
			create_link \
				"${SCRIPT_DIR}/../git/.gitconfig.local" \
				"${HOME}/.gitconfig.local"
		fi

		####################################################
		# [markdownlint-cli2] .markdownlint-cli2.jsonc をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/markdownlint-cli2/.markdownlint-cli2.jsonc" \
			"${HOME}/.markdownlint-cli2.jsonc"

		####################################################
		# [mise] config.toml をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../mise/config.toml" \
			"${HOME}/.config/mise/config.toml"

		####################################################
		# [pnpm] rc をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/pnpm/rc" \
			"${HOME}/.config/pnpm/rc"

		####################################################
		# [shell] .shellcheckrc をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/shellcheck/.shellcheckrc" \
			"${HOME}/.shellcheckrc"

		####################################################
		# [sqruff] .sqruff をリンクする
		####################################################
		# create_link \
		#   "${SCRIPT_DIR}/../.config/sqruff/.sqruff" \
		#   "${HOME}/.sqruff"

		####################################################
		# [Skills] skill ディレクトリをリンクする
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
		# [VS Code] settings.json (Remote) をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../vscode/settings-wsl/settings.json" \
			"${HOME}/.vscode-server/data/Machine/settings.json"

		####################################################
		# [VS Code] settings.json (User) をコピーする
		####################################################
		update_file \
			"${SCRIPT_DIR}/../vscode/settings-windows/settings.json" \
			"/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/settings.json"

		####################################################
		# [VS Code] tasks.json をコピーする
		####################################################
		update_file \
			"${SCRIPT_DIR}/../vscode/tasks.json" \
			"/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/tasks.json"

		####################################################
		# [VS Code] keybindings.json をコピーする
		####################################################
		update_file \
			"${SCRIPT_DIR}/../vscode/keybindings.json" \
			"/mnt/c/Users/${window_user_name}/AppData/Roaming/Code/User/keybindings.json"

		####################################################
		# [VS Code] スニペットをコピーする
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
		# [PowerShell] Advanced Function を設定する
		####################################################
		# ExecutionPolicy を更新する。
		powershell.exe -NoProfile -Command '& {
			if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
				Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
			}
		}'

		local pwsh_modules_dir="/mnt/c/Users/${window_user_name}/Documents/WindowsPowerShell/Modules"
		local pwsh_modules_dir_win="C:\\Users\\${window_user_name}\\Documents\\WindowsPowerShell\\Modules"

		# PSModulePath に module 配置先ディレクトリを追加する。
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

		####################################################
		# [Python] pip.conf をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/pip/pip.conf" \
			"${HOME}/.config/pip/pip.conf"

		####################################################
		# [Python] pyrightconfig.json をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/pyright/pyrightconfig.json" \
			"${HOME}/pyrightconfig.json"

		####################################################
		# [Python] ruff 設定をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/ruff/.ruff.toml" \
			"${HOME}/.config/ruff/.ruff.toml"

		####################################################
		# [Python] uv.toml をリンクする
		####################################################
		create_link \
			"${SCRIPT_DIR}/../.config/uv/uv.toml" \
			"${HOME}/.config/uv/uv.toml"

	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
