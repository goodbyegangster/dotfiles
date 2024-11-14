.PHONY: help
.DEFAULT_GOAL := help
help:
	@printf "%-30s %-60s\n" "[Sub command]" "[Description]"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %-60s\n", $$1, $$2}'

.PHONY: link
link: ## create symbolic link files.
	@bash ./scripts/link.sh

.PHONY: install_tools
install_tools: ## install tools.
	@bash ./scripts/install_tools.sh
