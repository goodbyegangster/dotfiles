#!/usr/bin/env bash
set -Eeuo pipefail

###################################################################################################
# Lake Formation 向け IAM ユーザーの作成 or 削除
#
# 下記ページに記載されているユーザー種類毎に、必要となる権限を付与した IAM ユーザーを作成する
# Lake Formation personas and IAM permissions reference - Personas suggested permissions
# https://docs.aws.amazon.com/lake-formation/latest/dg/permissions-reference.html#lf-permissions-tables
#
# 備考
# - ワークフロー・ロールのパスロール・ポリシーは付与させていない
# - Athena Query の Result 出力先として「S3://aws-athena-query-results-*」を指定しており、バケット名が異なる場合はコード側を修正する
###################################################################################################

function usage() {
	cat <<-EOF
		Usage:
			$(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] -p <aws profile> -t <policy type> -u <iam user name>

		Lake Formation 向け IAM ユーザーの作成 or 削除

		Available options:

		-h, --help
		-v, --verbose
		-d, --delete  削除したい場合に指定
		-p, --profile  利用する AWS プロファイル名
		-t, --type  ユーザーの権限タイプを右より指定 [admin, read_only_admin, engineer, analyst, scientist]
		-u, --user-name  IAM ユーザー名
	EOF
	exit
}

function msg() {
	echo >&2 -e "${1:-}"
}

function die() {
	local msg=$1
	local code=${2:-1}
	msg "$msg"
	exit "$code"
}

function parse_args() {
	ACCOUNT_ID=$(aws --profile private sts get-caller-identity | jq -r '.Account')
	ATHENA_QUERY_RESULT_BUCKET="aws-athena-query-results-*"
	should_delete=0

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		-p | --profile)
			PROFILE="${2:-}"
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
		-d | --delete) should_delete=1 ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	[[ -z "${PROFILE:-}" ]] && die "Missing required parameter: --profile"
	[[ -z "${USERNAME:-}" ]] && die "Missing required parameter: --user-name"

	if [[ ${should_delete} -eq 0 ]]; then
		[[ -z "${TYPE:-}" ]] && die "Missing required parameter: --type"
	fi

	return 0
}

function validate_type() {
	POLICY_TYPES="admin read_only_admin engineer analyst scientist"
	echo "${POLICY_TYPES}" | grep -w "${TYPE}" 1>/dev/null || die "Cold not match. ${TYPE} in ${POLICY_TYPES}"
}

function create_user() {
	aws --profile "${PROFILE}" iam create-user --user-name "${USERNAME}" 1>/dev/null
	aws --profile "${PROFILE}" iam create-login-profile --user-name "${USERNAME}" --password P@ssw0rd 1>/dev/null

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

function create_user_admin() {
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin
	# service-role 向けポリシーのため、IAM ユーザーにはアタッチ不要
	# aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/aws-service-role/LakeFormationDataAccessServiceRolePolicy
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AWSLakeFormationCrossAccountManager
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AmazonAthenaFullAccess
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
						"Resource": "arn:aws:iam::${ACCOUNT_ID}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
					}
				]
			}
		EOF
	)
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-admin --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-admin-cross-account --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-athena-result-bucket --policy-document "${policy}"
}

function create_user_read_only_admin() {
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-read-only-admin --policy-document "${policy}"
}

function create_user_engineer() {
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AmazonAthenaFullAccess
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-engineer --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-engineer-lf --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-engineer-tbac --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-athena-result-bucket --policy-document "${policy}"
}

function create_user_analyst() {
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AmazonAthenaFullAccess
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-analyst --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-analyst-lf --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-athena-result-bucket --policy-document "${policy}"
}

function create_user_scientist() {
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AmazonAthenaFullAccess
	aws --profile "${PROFILE}" iam attach-user-policy --user-name "${USERNAME}" --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-scientist --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-lf-data-scientist-lf --policy-document "${policy}"
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
	aws --profile "${PROFILE}" iam put-user-policy --user-name "${USERNAME}" --policy-name pol-athena-result-bucket --policy-document "${policy}"
}

function delete_user() {
	for attached_user_policy in $(aws --profile "${PROFILE}" iam list-attached-user-policies --user "${USERNAME}" | jq -r '.AttachedPolicies[].PolicyArn'); do
		aws --profile "${PROFILE}" iam detach-user-policy --user-name "${USERNAME}" --policy-arn "${attached_user_policy}"
	done
	for inline_policy in $(aws --profile "${PROFILE}" iam list-user-policies --user "${USERNAME}" | jq -r '.PolicyNames[]'); do
		aws --profile "${PROFILE}" iam delete-user-policy --user-name "${USERNAME}" --policy-name "${inline_policy}"
	done
	aws --profile "${PROFILE}" iam delete-login-profile --user-name "${USERNAME}" || msg "Login Profile cannot be found"
	aws --profile "${PROFILE}" iam delete-user --user-name "${USERNAME}"
	msg "delete user ${USERNAME}"
}

function main() {
	parse_args "$@"

	if [[ ${should_delete} -eq 0 ]]; then
		create_user
	else
		delete_user
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
