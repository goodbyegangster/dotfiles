#!/usr/bin/env bash
set -Eeuo pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

function run_install_script() {
	targets=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -name "*.sh" | \
	  grep -v "_install.sh" | \
	  xargs -n 1 basename | \
	  sed 's/^\(.*\)\.sh$/\1/' | \
	  sort
	)
	echo "Select scripts to execute:"
	select target in $targets; do
		if [[ -n "$target" ]]; then
			echo "Executing ${SCRIPT_DIR}/${target}.sh ..."
			bash "${SCRIPT_DIR}/${target}.sh"
			break
		else
			echo "Invalid selection. Please try again."
		fi
	done
}

function main() {
	run_install_script
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
