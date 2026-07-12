#!/usr/bin/env bash
set -Eeuo pipefail

CODEX_CLI_TMPDIR=""

function cleanup() {
	if [[ -n "$CODEX_CLI_TMPDIR" ]]; then
		rm -rf "$CODEX_CLI_TMPDIR"
	fi
}

function install() {
	# https://github.com/openai/codex#installing-and-running-codex-cli
	CODEX_CLI_TMPDIR=$(mktemp -d)
	trap cleanup EXIT

	curl -fsSLo "${CODEX_CLI_TMPDIR}/install.sh" \
	  https://chatgpt.com/codex/install.sh
	sh "${CODEX_CLI_TMPDIR}/install.sh"
}

function main() {
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
