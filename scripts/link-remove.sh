#!/usr/bin/env bash
#
# link-update.sh が作成した古いシンボリックリンクのバックアップを削除する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

readonly GREEN='\033[0;32m'
readonly RESET='\033[0m'

# 対象ディレクトリ内の古いシンボリックリンクのバックアップを削除する。
#
# 引数
#   $1: 対象ディレクトリ
remove_links() {
	local -a files
	local file

	local target_dir=$1

	[[ -d "$target_dir" ]] || return 0

	mapfile -t files < <(
		find "$target_dir" \
			-maxdepth 1 \
			-type l \
			-regextype sed \
			-regex ".*\.[0-9]\{14\}$" \
			| sort
	)
	for file in "${files[@]}"; do
		echo "rm ${file}"
		# 古いバックアップシンボリックリンクを削除する。
		rm "$file"
	done
}

main() {
	echo -e "${GREEN}Remove symbolic links${RESET}"

	remove_links "${HOME}"
	remove_links "${HOME}/.agents/skills/"
	remove_links "${HOME}/.claude/skills/"
	remove_links "${HOME}/.config/biome"
	remove_links "${HOME}/.config/mise"
	remove_links "${HOME}/.config/pip"
	remove_links "${HOME}/.config/pnpm"
	remove_links "${HOME}/.config/ruff"
	remove_links "${HOME}/.config/uv"
	remove_links "${HOME}/.vscode-server/data/Machine"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
