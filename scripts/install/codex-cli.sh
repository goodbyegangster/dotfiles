#!/usr/bin/env bash
#
# Codex CLI のインストールスクリプトを取得して実行する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

CODEX_CLI_TMPDIR=""

# 一時ディレクトリを削除する。
cleanup() {
	if [[ -n "$CODEX_CLI_TMPDIR" ]]; then
		# ダウンロード用の一時ディレクトリを削除する。
		rm -rf "$CODEX_CLI_TMPDIR"
	fi
}

# Codex CLI をインストールする。
install() {
	# https://github.com/openai/codex#installing-and-running-codex-cli
	CODEX_CLI_TMPDIR=$(mktemp -d)
	trap cleanup EXIT

	# Codex CLI のインストールスクリプトをダウンロードする。
	curl -fsSLo "${CODEX_CLI_TMPDIR}/install.sh" \
		https://chatgpt.com/codex/install.sh
	# Codex CLI のインストールスクリプトを実行する。
	sh "${CODEX_CLI_TMPDIR}/install.sh"
}

# Codex CLI のインストールを実行する。
main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
