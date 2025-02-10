.DEFAULT_GOAL := help

.PHONY: help
help:
	@printf "%-30s %-60s\n" "[Sub command]" "[Description]"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %-60s\n", $$1, $$2}'

.PHONY: link
link: ## create symbolic link files.
	@bash ./scripts/link.sh

.PHONY: remove-link
remove-link: ## remove old backup links.
	@bash ./scripts/remove-link.sh

.PHONY: install_tools
install_tools: ## install tools.
	@bash ./scripts/install_tools.sh

.PHONY: install_dbt_cloud_cli
install_dbt_cloud_cli: ## install dbt Cloud cli.
	@bash ./scripts/install/dbt_cloud_cli.sh

.PHONY: install_kubectl
install_kubectl: ## install kubectl.
	@bash ./scripts/install/kubectl.sh
