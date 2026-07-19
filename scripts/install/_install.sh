#!/usr/bin/env bash
#
# scripts/install 配下のインストールスクリプトを選択して実行する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_DIR

# インストールスクリプトを選択して実行する。
run_install_script() {
	local -a targets
	local target

	mapfile -t targets < <(
		find "$SCRIPT_DIR" \
			-maxdepth 1 \
			-type f \
			-name "*.sh" \
			! -name "_install.sh" \
			-printf "%f\n" \
			| sed 's/[.]sh$//' \
			| sort
	)

	if [[ "${#targets[@]}" -eq 0 ]]; then
		echo "No install scripts found."
		return 1
	fi

	echo "Select scripts to execute:"
	select target in "${targets[@]}"; do
		if [[ -n "$target" ]]; then
			echo "Executing ${SCRIPT_DIR}/${target}.sh ..."
			# 選択したインストールスクリプトを実行する。
			bash "${SCRIPT_DIR}/${target}.sh"
			break
		else
			echo "Invalid selection. Please try again."
		fi
	done
}

# インストールスクリプト選択処理を開始する。
main() {
	run_install_script
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
