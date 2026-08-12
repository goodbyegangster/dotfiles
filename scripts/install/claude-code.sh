#!/usr/bin/env bash
#
# Claude Code のネイティブインストーラーを取得して実行する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

# Claude Code をインストールする。
install() {
	# https://docs.claude.com/en/docs/claude-code/setup#native-install
	curl -fsSL https://claude.ai/install.sh | bash
}

# Claude Code のインストールを実行する。
main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
