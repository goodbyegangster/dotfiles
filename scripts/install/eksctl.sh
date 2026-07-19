#!/usr/bin/env bash
#
# eksctl を GitHub Releases の tarball からインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

EKSCTL_TMPDIR=""

# 一時ディレクトリを削除する。
cleanup() {
	if [[ -n "$EKSCTL_TMPDIR" ]]; then
		# ダウンロード用の一時ディレクトリを削除する。
		rm -rf "$EKSCTL_TMPDIR"
	fi
}

# eksctl をインストールする。
install_eksctl() {
	local -r arch=amd64
	local platform

	# 公式 GitHub Releases からのインストールが推奨されている。
	# https://github.com/eksctl-io/eksctl?tab=readme-ov-file#installation
	# https://github.com/eksctl-io/eksctl?tab=readme-ov-file#for-unix
	if ! command -v eksctl &>/dev/null; then
		platform="$(uname -s)_${arch}"

		EKSCTL_TMPDIR=$(mktemp -d)
		trap cleanup EXIT

		pushd "$EKSCTL_TMPDIR" >/dev/null

		# eksctl の tarball と checksums をダウンロードする。
		curl -sLO \
			"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${platform}.tar.gz"
		curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" \
			| grep "$platform" \
			| sha256sum --check

		tar -xzf "eksctl_${platform}.tar.gz"
		# eksctl を /usr/local/bin へインストールする。
		sudo install -m 0755 eksctl /usr/local/bin/eksctl

		popd >/dev/null
	fi
}

# eksctl のインストールを実行する。
main() {
	install_eksctl
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
