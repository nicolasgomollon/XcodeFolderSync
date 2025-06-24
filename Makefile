.PHONY: build
build: ## Build the project and copy the executable to the current directory
	@swift build --configuration release
	@cp -f .build/release/xcode-folder-sync .

.PHONY: clean
clean: ## Remove the build directory and compiled executable
	@rm -rfv .build xcode-folder-sync

.PHONY: install
install: build ## Build the project and install the executable in `/usr/local/bin/`
	@sudo cp -fv xcode-folder-sync /usr/local/bin/

.PHONY: uninstall
uninstall: ## Remove the executable from `/usr/local/bin/`
	@sudo rm -fv /usr/local/bin/xcode-folder-sync

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'