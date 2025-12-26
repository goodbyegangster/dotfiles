.DEFAULT_GOAL := help

.PHONY: help
help:
	@printf "%-30s %-60s\n" "[Sub command]" "[Description]"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %-60s\n", $$1, $$2}'

.PHONY: link-update
link-update: ## create/update symbolic link files.
	@bash ./scripts/link-update.sh

.PHONY: link-remove
link-remove: ## remove old backup links.
	@bash ./scripts/link-remove.sh

.PHONY: install-basic
install-basic: ## install tools.
	@bash ./scripts/install/basic.sh

.PHONY: install-dbt-cloud-cli
install-dbt-cloud-cli: ## install dbt Cloud cli.
	@bash ./scripts/install/dbt-cloud-cli.sh

.PHONY: install-kubectl
install-kubectl: ## install kubectl.
	@bash ./scripts/install/kubectl.sh
