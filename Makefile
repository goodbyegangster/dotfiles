.DEFAULT_GOAL := help

.PHONY: help
help:
	@printf "%-30s %-60s\n" "[Sub command]" "[Description]"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %-60s\n", $$1, $$2}'

.PHONY: link-update
link-update: ## Create or update symbolic links.
	@bash ./scripts/link-update.sh

.PHONY: link-remove
link-remove: ## Remove old backup links.
	@bash ./scripts/link-remove.sh

.PHONY: install-mise
install-mise: ## install mise (minimal setup).
	@bash ./scripts/install/mise.sh

.PHONY: run-install-scripts
run-install-scripts: ## Execute the installation scripts.
	@bash ./scripts/install/_install.sh
