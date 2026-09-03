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
	local arch
	local platform
	local checksum_cmd

	# 公式 GitHub Releases からのインストールが推奨されている。
	# https://github.com/eksctl-io/eksctl?tab=readme-ov-file#installation
	# https://github.com/eksctl-io/eksctl?tab=readme-ov-file#for-unix
	if ! command -v eksctl &>/dev/null; then
		case "$(uname -m)" in
			x86_64) arch=amd64 ;;
			arm64 | aarch64) arch=arm64 ;;
			*)
				echo "unsupported architecture: $(uname -m)" >&2
				exit 1
				;;
		esac

		# macOS には sha256sum が標準搭載されていないため shasum を利用する。
		case "$(uname -s)" in
			Linux) checksum_cmd=(sha256sum --check) ;;
			Darwin) checksum_cmd=(shasum -a 256 --check) ;;
			*)
				echo "unsupported platform: $(uname -s)" >&2
				exit 1
				;;
		esac

		platform="$(uname -s)_${arch}"

		EKSCTL_TMPDIR=$(mktemp -d)
		trap cleanup EXIT

		pushd "$EKSCTL_TMPDIR" >/dev/null

		# eksctl の tarball と checksums をダウンロードする。
		curl -sLO \
			"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${platform}.tar.gz"
		curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" \
			| grep "$platform" \
			| "${checksum_cmd[@]}"

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
