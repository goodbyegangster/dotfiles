#!/usr/bin/env bash
set -Eeuo pipefail

VERSION=""

function get_user_input() {
	echo "Release: https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/rsql-query-tool-changelog.html"
	read -erp "please input version(X.X.X): " VERSION
}

function install() {
	local odbc_version

	pushd "${HOME}" > /dev/null

	sudo apt-get update -y
	sudo apt-get install -y \
	  alien \
	  dpkg-dev \
	  debhelper \
	  build-essential \
	  unixodbc \
	  unixodbc-dev

	###########################################################################
	# Redshift ODBC Driver
	###########################################################################
	# Downloading and installing the Amazon Redshift ODBC driver
	# https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/odbc20-install-linux.html

	odbc_version="2.1.12.0"

	local odbc_rpm="AmazonRedshiftODBC-64-bit-${odbc_version}.x86_64.rpm"
	local odbc_url="https://s3.amazonaws.com/redshift-downloads/drivers/odbc/${odbc_version}/${odbc_rpm}"

	wget "${odbc_url}"

	# deb ファイルに変換してインストール
	sudo alien -i "${odbc_rpm}"
	rm "${odbc_rpm}"

	if [[ -f /opt/amazon/redshiftodbcx64/odbc.ini ]]; then
		cp /opt/amazon/redshiftodbcx64/odbc.ini ~/.odbc.ini
	else
		echo "Warning: /opt/amazon/redshiftodbcx64/odbc.ini not found."
		exit 1
	fi

	export ODBCINI=~/.odbc.ini
	export ODBCSYSINI=/opt/amazon/redshiftodbcx64/
	export AMAZONREDSHIFTODBCINI=/opt/amazon/redshiftodbcx64/amazon.redshiftodbc.ini

	###########################################################################
	# Redshift RSQL
	###########################################################################
	# Getting started with Amazon Redshift RSQL
	# https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/rsql-query-tool-getting-started.html

	local rsql_rpm="AmazonRedshiftRsql-${VERSION}.rhel.x86_64.rpm"
	local rsql_url="https://s3.amazonaws.com/redshift-downloads/amazon-redshift-rsql/${VERSION}/${rsql_rpm}"

	wget "${rsql_url}"

	# deb ファイルに変換してインストール
	sudo alien -i "${rsql_rpm}"
	rm "${rsql_rpm}"

	# symbolic link 作成
	installed_path="/usr/share/aws/rsql/bin/rsql"
	if [[ -n "$installed_path" ]]; then
		sudo ln -sf "$installed_path" /usr/local/bin/rsql
		echo "link created: /usr/local/bin/rsql -> $installed_path"
	else
		echo "Error: Could not find rsql binary in expected locations."
		echo "Please check 'dpkg -L amazonredshiftrsql' manually."
	fi

	popd > /dev/null
}

function main() {
	get_user_input
	install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi
