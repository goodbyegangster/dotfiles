#!/usr/bin/env bash
#
# Lake Formation 向け IAM ユーザーの作成または削除を行う。
#
# 下記ページに記載されているユーザー種類毎に、必要となる権限を付与した IAM ユーザーを作成する
# Lake Formation personas and IAM permissions reference - Personas suggested permissions
# https://docs.aws.amazon.com/lake-formation/latest/dg/permissions-reference.html#lf-permissions-tables
#
# 備考
# - ワークフロー・ロールのパスロール・ポリシーは付与させていない
# - Athena Query の Result 出力先として「S3://aws-athena-query-results-*」を指定しており、バケット名が異なる場合はコード側を修正する
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

readonly ATHENA_QUERY_RESULT_BUCKET="aws-athena-query-results-*"
readonly POLICY_TYPES="admin read_only_admin engineer analyst scientist"

ACCOUNT_ID=""
PASSWORD="${LAKE_FORMATION_USER_PASSWORD:-}"
PROFILE=""
SHOULD_DELETE=0
TYPE=""
USERNAME=""

# 使い方を標準出力へ表示する。
usage() {
	cat <<-EOF
		Usage:
		  $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] -p <aws profile> -u <iam user name>
		  $(basename "${BASH_SOURCE[0]}") [-h] [-v] -p <aws profile> -t <policy type> \\
		    -u <iam user name> [-P <password>]

		Lake Formation 向け IAM ユーザーの作成または削除を行う。

		Available options:

		-h, --help
		-v, --verbose
		-d, --delete    IAM ユーザーを削除する
		-p, --profile   利用する AWS プロファイル名
		-t, --type      ユーザーの権限タイプ [admin, read_only_admin, engineer, analyst, scientist]
		-u, --user-name IAM ユーザー名
		-P, --password  ログインパスワード

		Environment variables:

		LAKE_FORMATION_USER_PASSWORD
		  --password 未指定時のログインパスワード
	EOF
	exit
}

# メッセージを標準エラー出力へ表示する。
#
# 引数
#   $1: 表示するメッセージ
msg() {
	printf "%b\n" "${1:-}" >&2
}

# エラーメッセージを表示して終了する。
#
# 引数
#   $1: 表示するメッセージ
#   $2: 終了ステータス
die() {
	local msg=$1
	local code=${2:-1}

	msg "$msg"
	exit "$code"
}

# AWS IAM コマンドを指定 profile で実行する。
aws_iam() {
	aws --profile "${PROFILE}" iam "$@"
}

# 管理ポリシーを IAM ユーザーへアタッチする。
#
# 引数
#   $1: 管理ポリシー ARN
attach_user_policy() {
	local policy_arn=$1

	# IAM ユーザーへ管理ポリシーをアタッチする。
	aws_iam attach-user-policy \
		--user-name "${USERNAME}" \
		--policy-arn "$policy_arn"
}

# inline policy を IAM ユーザーへ追加する。
#
# 引数
#   $1: policy 名
#   $2: policy document
put_user_policy() {
	local policy_name=$1
	local policy_document=$2

	# IAM ユーザーへ inline policy を追加する。
	aws_iam put-user-policy \
		--user-name "${USERNAME}" \
		--policy-name "$policy_name" \
		--policy-document "$policy_document"
}

# コマンドライン引数を解析する。
parse_args() {
	while :; do
		case "${1-}" in
			-h | --help) usage ;;
			-v | --verbose) set -x ;;
			-d | --delete) SHOULD_DELETE=1 ;;
			-p | --profile)
				PROFILE="${2:-}"
				shift
				;;
			-P | --password)
				PASSWORD="${2:-}"
				shift
				;;
			-t | --type)
				TYPE="${2:-}"
				validate_type
				shift
				;;
			-u | --user-name)
				USERNAME="${2:-}"
				shift
				;;
			-?*) die "Unknown option: $1" ;;
			*) break ;;
		esac
		shift
	done

	[[ -z "${PROFILE}" ]] && die "Missing required parameter: --profile"
	[[ -z "${USERNAME}" ]] && die "Missing required parameter: --user-name"

	if [[ "${SHOULD_DELETE}" -eq 0 ]]; then
		[[ -z "${TYPE}" ]] && die "Missing required parameter: --type"
		[[ -z "${PASSWORD}" ]] && die "Missing required parameter: --password"
	fi

	ACCOUNT_ID="$(aws --profile "${PROFILE}" sts get-caller-identity --query Account --output text)"
}

# 権限タイプが許可値に含まれることを検証する。
validate_type() {
	case " ${POLICY_TYPES} " in
		*" ${TYPE} "*) ;;
		*) die "Could not match. ${TYPE} in ${POLICY_TYPES}" ;;
	esac
}

# IAM ユーザーを作成し、権限タイプに応じた policy を付与する。
create_user() {
	# IAM ユーザーとログインプロファイルを作成する。
	aws_iam create-user --user-name "${USERNAME}" 1>/dev/null
	aws_iam create-login-profile \
		--user-name "${USERNAME}" \
		--password "${PASSWORD}" \
		--password-reset-required \
		1>/dev/null

	case "${TYPE}" in
		admin)
			create_user_admin
			;;
		read_only_admin)
			create_user_read_only_admin
			;;
		engineer)
			create_user_engineer
			;;
		analyst)
			create_user_analyst
			;;
		scientist)
			create_user_scientist
			;;
	esac

	msg "create user ${USERNAME}: ${TYPE}"
}

# admin 向け policy を付与する。
create_user_admin() {
	local policy
	local service_role_arn

	attach_user_policy "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin"
	# service-role 向けポリシーのため、IAM ユーザーにはアタッチ不要。
	# arn:aws:iam::aws:policy/aws-service-role/LakeFormationDataAccessServiceRolePolicy
	attach_user_policy "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
	attach_user_policy "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
	attach_user_policy "arn:aws:iam::aws:policy/AWSLakeFormationCrossAccountManager"
	attach_user_policy "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"

	service_role_arn="arn:aws:iam::${ACCOUNT_ID}:role/aws-service-role"
	service_role_arn="${service_role_arn}/lakeformation.amazonaws.com"
	service_role_arn="${service_role_arn}/AWSServiceRoleForLakeFormationDataAccess"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": "iam:CreateServiceLinkedRole",
						"Resource": "*",
						"Condition": {
							"StringEquals": {
								"iam:AWSServiceName": "lakeformation.amazonaws.com"
							}
						}
					},
					{
						"Effect": "Allow",
						"Action": [
							"iam:PutRolePolicy"
						],
						"Resource": "${service_role_arn}"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-admin" "$policy"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"ram:AcceptResourceShareInvitation",
							"ram:RejectResourceShareInvitation",
							"ec2:DescribeAvailabilityZones",
							"ram:EnableSharingWithAwsOrganization"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-admin-cross-account" "$policy"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"s3:Put*",
							"s3:Get*",
							"s3:List*"
						],
						"Resource": "arn:aws:s3:::${ATHENA_QUERY_RESULT_BUCKET}"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-athena-result-bucket" "$policy"
}

# read_only_admin 向け policy を付与する。
create_user_read_only_admin() {
	local policy

	policy=$(
		cat <<-EOF
			{
				"Version":"2012-10-17",
				"Statement":[
					{
						"Effect":"Allow",
						"Action":[
							"lakeformation:GetEffectivePermissionsForPath",
							"lakeformation:ListPermissions",
							"lakeformation:ListDataCellsFilter",
							"lakeformation:GetDataCellsFilter",
							"lakeformation:SearchDatabasesByLFTags",
							"lakeformation:SearchTablesByLFTags",
							"lakeformation:GetLFTag",
							"lakeformation:ListLFTags",
							"lakeformation:GetResourceLFTags",
							"lakeformation:ListLakeFormationOptins",
							"cloudtrail:DescribeTrails",
							"cloudtrail:LookupEvents",
							"glue:GetDatabase",
							"glue:GetDatabases",
							"glue:GetConnections",
							"glue:SearchTables",
							"glue:GetTable",
							"glue:GetTableVersions",
							"glue:GetPartitions",
							"glue:GetTables",
							"glue:GetWorkflow",
							"glue:ListWorkflows",
							"glue:BatchGetWorkflows",
							"glue:GetWorkflowRuns",
							"glue:GetWorkflow",
							"s3:ListBucket",
							"s3:GetBucketLocation",
							"s3:ListAllMyBuckets",
							"s3:GetBucketAcl",
							"iam:ListUsers",
							"iam:ListRoles",
							"iam:GetRole",
							"iam:GetRolePolicy"
						],
						"Resource":"*"
					},
					{
						"Effect":"Deny",
						"Action":[
							"lakeformation:PutDataLakeSettings"
						],
						"Resource":"*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-read-only-admin" "$policy"
}

# engineer 向け policy を付与する。
create_user_engineer() {
	local policy

	attach_user_policy "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
	attach_user_policy "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:GetDataAccess",
							"lakeformation:GrantPermissions",
							"lakeformation:RevokePermissions",
							"lakeformation:BatchGrantPermissions",
							"lakeformation:BatchRevokePermissions",
							"lakeformation:ListPermissions",
							"lakeformation:AddLFTagsToResource",
							"lakeformation:RemoveLFTagsFromResource",
							"lakeformation:GetResourceLFTags",
							"lakeformation:ListLFTags",
							"lakeformation:GetLFTag",
							"lakeformation:SearchTablesByLFTags",
							"lakeformation:SearchDatabasesByLFTags",
							"lakeformation:GetWorkUnits",
							"lakeformation:GetWorkUnitResults",
							"lakeformation:StartQueryPlanning",
							"lakeformation:GetQueryState",
							"lakeformation:GetQueryStatistics"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-engineer" "$policy"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:StartTransaction",
							"lakeformation:CommitTransaction",
							"lakeformation:CancelTransaction",
							"lakeformation:ExtendTransaction",
							"lakeformation:DescribeTransaction",
							"lakeformation:ListTransactions",
							"lakeformation:GetTableObjects",
							"lakeformation:UpdateTableObjects",
							"lakeformation:DeleteObjectsOnCancel"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-engineer-lf" "$policy"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:AddLFTagsToResource",
							"lakeformation:RemoveLFTagsFromResource",
							"lakeformation:GetResourceLFTags",
							"lakeformation:ListLFTags",
							"lakeformation:GetLFTag",
							"lakeformation:SearchTablesByLFTags",
							"lakeformation:SearchDatabasesByLFTags"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-engineer-tbac" "$policy"

	put_athena_result_bucket_policy
}

# analyst 向け policy を付与する。
create_user_analyst() {
	local policy

	attach_user_policy "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:GetDataAccess",
							"glue:GetTable",
							"glue:GetTables",
							"glue:SearchTables",
							"glue:GetDatabase",
							"glue:GetDatabases",
							"glue:GetPartitions",
							"lakeformation:GetResourceLFTags",
							"lakeformation:ListLFTags",
							"lakeformation:GetLFTag",
							"lakeformation:SearchTablesByLFTags",
							"lakeformation:SearchDatabasesByLFTags"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-analyst" "$policy"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:StartTransaction",
							"lakeformation:CommitTransaction",
							"lakeformation:CancelTransaction",
							"lakeformation:ExtendTransaction",
							"lakeformation:DescribeTransaction",
							"lakeformation:ListTransactions",
							"lakeformation:GetTableObjects",
							"lakeformation:UpdateTableObjects",
							"lakeformation:DeleteObjectsOnCancel"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-analyst-lf" "$policy"

	put_athena_result_bucket_policy
}

# scientist 向け policy を付与する。
create_user_scientist() {
	local policy

	attach_user_policy "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
	attach_user_policy "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:GetDataAccess",
							"glue:GetTable",
							"glue:GetTables",
							"glue:SearchTables",
							"glue:GetDatabase",
							"glue:GetDatabases",
							"glue:GetPartitions",
							"lakeformation:GetResourceLFTags",
							"lakeformation:ListLFTags",
							"lakeformation:GetLFTag",
							"lakeformation:SearchTablesByLFTags",
							"lakeformation:SearchDatabasesByLFTags"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-scientist" "$policy"

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"lakeformation:StartTransaction",
							"lakeformation:CommitTransaction",
							"lakeformation:CancelTransaction",
							"lakeformation:ExtendTransaction",
							"lakeformation:DescribeTransaction",
							"lakeformation:ListTransactions",
							"lakeformation:GetTableObjects",
							"lakeformation:UpdateTableObjects",
							"lakeformation:DeleteObjectsOnCancel"
						],
						"Resource": "*"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-lf-data-scientist-lf" "$policy"

	put_athena_result_bucket_policy
}

# Athena query result bucket 向け policy を付与する。
put_athena_result_bucket_policy() {
	local policy

	policy=$(
		cat <<-EOF
			{
				"Version": "2012-10-17",
				"Statement": [
					{
						"Effect": "Allow",
						"Action": [
							"s3:Put*",
							"s3:Get*",
							"s3:List*"
						],
						"Resource": "arn:aws:s3:::${ATHENA_QUERY_RESULT_BUCKET}"
					}
				]
			}
		EOF
	)
	put_user_policy "pol-athena-result-bucket" "$policy"
}

# IAM ユーザーと関連する policy を削除する。
delete_user() {
	local -a attached_user_policies
	local -a inline_policies
	local attached_user_policy
	local inline_policy

	mapfile -t attached_user_policies < <(
		aws_iam list-attached-user-policies \
			--user-name "${USERNAME}" \
			| jq -r '.AttachedPolicies[].PolicyArn'
	)
	for attached_user_policy in "${attached_user_policies[@]}"; do
		[[ -n "$attached_user_policy" ]] || continue
		# IAM ユーザーから管理ポリシーをデタッチする。
		aws_iam detach-user-policy \
			--user-name "${USERNAME}" \
			--policy-arn "$attached_user_policy"
	done

	mapfile -t inline_policies < <(
		aws_iam list-user-policies \
			--user-name "${USERNAME}" \
			| jq -r '.PolicyNames[]'
	)
	for inline_policy in "${inline_policies[@]}"; do
		[[ -n "$inline_policy" ]] || continue
		# IAM ユーザーから inline policy を削除する。
		aws_iam delete-user-policy \
			--user-name "${USERNAME}" \
			--policy-name "$inline_policy"
	done

	# IAM ユーザーのログインプロファイルを削除する。
	aws_iam delete-login-profile --user-name "${USERNAME}" \
		|| msg "Login Profile cannot be found"
	# IAM ユーザーを削除する。
	aws_iam delete-user --user-name "${USERNAME}"
	msg "delete user ${USERNAME}"
}

# 引数に応じて IAM ユーザーの作成または削除を実行する。
main() {
	parse_args "$@"

	if [[ "${SHOULD_DELETE}" -eq 0 ]]; then
		create_user
	else
		delete_user
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
