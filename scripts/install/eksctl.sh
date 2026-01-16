#!/usr/bin/env bash
# shellcheck disable=SC2155
set -Eeuo pipefail

# NOTES
# eksctl is available to install from official releases as described below.
# We recommend that you install eksctl from only the official GitHub releases.
# You may opt to use a third-party installer, but please be advised that AWS does not maintain nor support these methods of installation.
# Use them at your own discretion.
# https://github.com/eksctl-io/eksctl?tab=readme-ov-file#installation

function install_eksctl() {
	# https://github.com/eksctl-io/eksctl?tab=readme-ov-file#for-unix
	if ! command -v eksctl &>/dev/null; then
		readonly ARCH=amd64
		readonly PLATFORM="$(uname -s)_${ARCH}"

		readonly TMP_DIR=$(mktemp -d)
		trap 'rm -rf "$TMP_DIR"' EXIT

		pushd "$TMP_DIR" >/dev/null

		curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
		curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" \
		  | grep "$PLATFORM" \
		  | sha256sum --check

		tar -xzf "eksctl_${PLATFORM}.tar.gz"
		sudo install -m 0755 eksctl /usr/local/bin/eksctl

		popd >/dev/null
	fi
}

function main() {
	install_eksctl
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
