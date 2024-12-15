#!/usr/bin/env bash
set -Eeuo pipefail

function main() {
	printf "\033[32m%s\033[m\n" "Remove symbolic links"
	mapfile -t files < <(find "$HOME" -maxdepth 1 -type l -regextype sed -regex ".*[0-9]\{14\}$" | sort)
	for file in "${files[@]}"; do
		echo "rm ${file}"
		rm "$file"
	done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
