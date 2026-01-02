#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2155

#####################################################
# 基本設定
#####################################################

export EDITOR=vim

# 1Password（Windows 側にインストールされた CLI を呼ぶ）
alias op='op.exe'

#####################################################
# git
#####################################################

# GitHub CLI
# https://cli.github.com/manual/gh_completion
if command -v gh &> /dev/null; then
	eval "$(gh completion -s bash)"
	export GH_BROWSER="'/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'"
fi

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
# Google Cloud
#####################################################

# Google Cloud SDK
export GCLOUD_HOME="$HOME/google-cloud-sdk"
if [[ -f "$GCLOUD_HOME/path.bash.inc" ]]; then
    . "$GCLOUD_HOME/path.bash.inc"
fi
if [[ -f "$GCLOUD_HOME/completion.bash.inc" ]]; then
    . "$GCLOUD_HOME/completion.bash.inc"
fi

#####################################################
# Microsoft
#####################################################

# sqlcmd, bcp (SQLServer)
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

# tfenv
case ":$PATH:" in
	*":$HOME/.tfenv/bin:"*) ;;
	*) export PATH="$HOME/.tfenv/bin:$PATH" ;;
esac

#####################################################
# Docker
#####################################################

# rootless-docker
# https://docs.docker.com/engine/security/rootless/#install
if [[ -S "/run/user/$(id -u)/docker.sock" ]]; then
	export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
fi

#####################################################
# Kubernetes
#####################################################

# kubectl
# https://kubernetes.io/ja/docs/tasks/tools/install-kubectl-linux/#kubectl%E3%81%AE%E8%87%AA%E5%8B%95%E8%A3%9C%E5%AE%8C%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B
if command -v kubectl &> /dev/null; then
	source <(kubectl completion bash)
fi

# minikube
# https://minikube.sigs.k8s.io/docs/commands/completion/
# if command -v minikube &> /dev/null; then
# 	alias kubectl="minikube kubectl --"
# 	source <(minikube completion bash)
# fi

# helm
# https://helm.sh/docs/helm/helm_completion_bash/
if command -v helm &> /dev/null; then
	source <(helm completion bash)
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
# Python
#####################################################

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
case ":$PATH:" in
	*":$PYENV_ROOT:"*) ;;
	*) export PATH="$PYENV_ROOT/bin:$PATH" ;;
esac

if command -v pyenv &> /dev/null; then
	eval "$(pyenv init -)"
fi

# uv
# https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
if command -v uv &> /dev/null; then
	eval "$(~/.local/bin/uv generate-shell-completion bash)"
fi

#####################################################
# JavaScript / TypeScript
#####################################################

# nvm
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
	. "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
	. "$NVM_DIR/bash_completion"
fi

# Deno
export DENO_INSTALL="$HOME/.deno"
case ":$PATH:" in
	*":$DENO_INSTALL/bin:"*) ;;
	*) export PATH="$DENO_INSTALL/bin:$PATH" ;;
esac

# https://docs.deno.com/runtime/reference/cli/completions/
if command -v deno &> /dev/null; then
	source <(deno completions bash)
fi

# npm は利用しない
alias npm='echo "WARNING: do not use npm. Use pnpm instead." && false'
alias npx='echo "WARNING: do not use npx. Use pnpm dlx instead." && false'
# if command -v npm &> /dev/null; then
# 	eval "$(npm completion)"
# fi

# yarn
case ":$PATH:" in
	*":$HOME/.yarn/bin:"*) ;;
	*) export PATH="$PATH:$HOME/.yarn/bin" ;;
esac

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
	*":$PNPM_HOME:"*) ;;
	*) export PATH="$PNPM_HOME:$PATH" ;;
esac

if command -v pnpm &> /dev/null; then
	source <(pnpm completion bash)
fi

#####################################################
# Go
#####################################################

# Go
case ":$PATH:" in
	*":/usr/local/go/bin:"*) ;;
	*) export PATH="$PATH:/usr/local/go/bin" ;;
esac
