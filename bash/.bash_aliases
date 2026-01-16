#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2155

export EDITOR=vim

#####################################################
# Windows 側アプリケーションの呼び出し
#####################################################

# Excel
function excel() {
    cmd.exe /c start excel.exe "$(wslpath -w "$1")"
}

# 1Password
alias op='op.exe'

#####################################################
# AWS
#####################################################

# AWS cli
# https://docs.aws.amazon.com/ja_jp/cli/v1/userguide/cli-configure-completion.html
if command -v aws_completer &> /dev/null; then
	complete -C "$(command -v aws_completer)" aws
fi

# AWSume
if command -v awsume &> /dev/null; then
	# https://awsu.me/general/quickstart.html#alias-setup
	alias awsume=". awsume"
	# https://awsu.me/utilities/awsume-configure.html#autocomplete-script
	_awsume() {
		local cur
		local opts
		COMPREPLY=()
		cur="${COMP_WORDS[COMP_CWORD]}"
		opts=$(awsume-autocomplete)
		mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
		return 0
	}
	complete -F _awsume awsume
fi

# aws-vault (backend として利用している pass 向けの情報)
if command -v aws-vault &> /dev/null; then
	export AWS_VAULT_BACKEND=pass
	export GPG_TTY=$(tty)
fi

# eksctl
# https://eksctl.io/installation/#shell-completion
if command -v eksctl &> /dev/null; then
	source <(eksctl completion bash)
fi

#####################################################
# direnv
#####################################################

# direnv
# https://direnv.net/docs/hook.html#bash
if command -v direnv &> /dev/null; then
	eval "$(direnv hook bash)"
fi

#####################################################
# Docker
#####################################################

# rootless-docker
# https://docs.docker.com/engine/security/rootless/#install
if [[ -S "/run/user/$(id -u)/docker.sock" ]]; then
	export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
fi

#####################################################
# GitHub
#####################################################

# GitHub CLI
# https://cli.github.com/manual/gh_completion
if command -v gh &> /dev/null; then
	eval "$(gh completion -s bash)"
	export GH_BROWSER="'/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'"
fi

#####################################################
# Google Cloud
#####################################################

# Google Cloud CLI
# Check install path with: gcloud info --format="value(installation.sdk_root)"
export GCLOUD_HOME="/usr/lib/google-cloud-sdk"
if [[ -f "$GCLOUD_HOME/path.bash.inc" ]]; then
	source "$GCLOUD_HOME/path.bash.inc"
fi
if [[ -f "$GCLOUD_HOME/completion.bash.inc" ]]; then
	source "$GCLOUD_HOME/completion.bash.inc"
fi

#####################################################
# JavaScript / TypeScript
#####################################################

# Deno
# https://docs.deno.com/runtime/reference/cli/completions/
if command -v deno &> /dev/null; then
	export DENO_INSTALL=$(which deno)
	source <(deno completions bash)
fi

# npm は利用しない
alias npm='echo "WARNING: do not use npm. Use pnpm instead." && false'
alias npx='echo "WARNING: do not use npx. Use pnpm dlx instead." && false'
# if command -v npm &> /dev/null; then
# 	eval "$(npm completion)"
# fi

# pnpm
if command -v pnpm &> /dev/null; then
	export PNPM_HOME=$(which pnpm)
	source <(pnpm completion bash)
fi

#####################################################
# Kubernetes
#####################################################

# kubectl
# https://kubernetes.io/ja/docs/tasks/tools/install-kubectl-linux/#kubectl%E3%81%AE%E8%87%AA%E5%8B%95%E8%A3%9C%E5%AE%8C%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B
if command -v kubectl &> /dev/null; then
	source <(kubectl completion bash)
fi

# helm
# https://helm.sh/docs/helm/helm_completion_bash/
if command -v helm &> /dev/null; then
	source <(helm completion bash)
fi

# minikube
# https://minikube.sigs.k8s.io/docs/commands/completion/
# if command -v minikube &> /dev/null; then
# 	alias kubectl="minikube kubectl --"
# 	source <(minikube completion bash)
# fi

#####################################################
# Python
#####################################################

# uv
# https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
if command -v uv &> /dev/null; then
	eval "$(uv generate-shell-completion bash)"
fi

#####################################################
# SQLServer
#####################################################

# https://learn.microsoft.com/ja-jp/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver16&tabs=ubuntu-install#ubuntu
case ":$PATH:" in
	*":/opt/mssql-tools18/bin:"*) ;;
	*) export PATH="$PATH:/opt/mssql-tools18/bin" ;;
esac

#####################################################
# Terraform
#####################################################

# Terraform
# https://developer.hashicorp.com/terraform/cli/commands#shell-tab-completion
if command -v terraform &> /dev/null; then
	complete -C terraform terraform
fi
