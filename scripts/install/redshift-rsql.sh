#!/usr/bin/env bash
#
# Amazon Redshift ODBC Driver と RSQL をインストールする。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

VERSION=""

# インストールする Redshift RSQL のバージョンを入力する。
get_user_input() {
	echo "Release:"
	echo "  https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/"
	echo "  rsql-query-tool-changelog.html"
	read -erp "please input version(X.X.X): " VERSION
}

# Redshift ODBC Driver と RSQL をインストールする。
install() {
	local installed_path
	local odbc_version
	local odbc_rpm
	local odbc_url
	local rsql_rpm
	local rsql_url

	pushd "${HOME}" >/dev/null

	# インストールに必要なパッケージを追加する。
	sudo apt-get update -y
	sudo apt-get install -y \
		alien \
		dpkg-dev \
		debhelper \
		build-essential \
		unixodbc \
		unixodbc-dev

	###########################################################################
	# Redshift ODBC Driver をインストールする
	###########################################################################
	# https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/odbc20-install-linux.html

	odbc_version="2.1.12.0"

	odbc_rpm="AmazonRedshiftODBC-64-bit-${odbc_version}.x86_64.rpm"
	odbc_url="https://s3.amazonaws.com/redshift-downloads/drivers/odbc"
	odbc_url="${odbc_url}/${odbc_version}/${odbc_rpm}"

	wget "${odbc_url}"

	# rpm ファイルを deb ファイルに変換してインストールする。
	sudo alien -i "${odbc_rpm}"
	# ダウンロードした rpm ファイルを削除する。
	rm "${odbc_rpm}"

	if [[ -f /opt/amazon/redshiftodbcx64/odbc.ini ]]; then
		# Redshift ODBC Driver の設定ファイルをホームへコピーする。
		cp /opt/amazon/redshiftodbcx64/odbc.ini ~/.odbc.ini
	else
		echo "Warning: /opt/amazon/redshiftodbcx64/odbc.ini not found."
		exit 1
	fi

	export ODBCINI=~/.odbc.ini
	export ODBCSYSINI=/opt/amazon/redshiftodbcx64/
	export AMAZONREDSHIFTODBCINI=/opt/amazon/redshiftodbcx64/amazon.redshiftodbc.ini

	###########################################################################
	# Redshift RSQL をインストールする
	###########################################################################
	# https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/rsql-query-tool-getting-started.html

	rsql_rpm="AmazonRedshiftRsql-${VERSION}.rhel.x86_64.rpm"
	rsql_url="https://s3.amazonaws.com/redshift-downloads/amazon-redshift-rsql"
	rsql_url="${rsql_url}/${VERSION}/${rsql_rpm}"

	wget "${rsql_url}"

	# rpm ファイルを deb ファイルに変換してインストールする。
	sudo alien -i "${rsql_rpm}"
	# ダウンロードした rpm ファイルを削除する。
	rm "${rsql_rpm}"

	installed_path="/usr/share/aws/rsql/bin/rsql"
	if [[ -x "$installed_path" ]]; then
		# rsql のシンボリックリンクを作成する。
		sudo ln -sf "$installed_path" /usr/local/bin/rsql
		echo "link created: /usr/local/bin/rsql -> $installed_path"
	else
		echo "Error: Could not find rsql binary in expected locations."
		echo "Please check 'dpkg -L amazonredshiftrsql' manually."
		return 1
	fi

	popd >/dev/null
}

# Redshift RSQL のバージョンを入力してインストールを実行する。
main() {
	get_user_input
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
