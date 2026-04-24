# Makefile for validating Grafana Alloy configurations
# Requires: alloy CLI installed locally (brew install grafana-alloy)

SHELL := /bin/bash
ALLOY := $(shell command -v alloy 2>/dev/null)
EXAMPLE_DIRS := $(wildcard examples/*/)
ALLOY_FILES := $(shell find modules examples -name '*.alloy' -not -name 'env-reference.alloy')

.PHONY: test validate fmt-check check-alloy help

## Run all checks (validate + fmt-check)
test: check-alloy validate fmt-check
	@echo ""
	@echo "All checks passed."

## Validate all example configurations with alloy validate
validate: check-alloy
	@echo "=== Validating example configurations ==="
	@failed=0; \
	for dir in $(EXAMPLE_DIRS); do \
		printf "  %-45s" "$$dir"; \
		output=$$($(ALLOY) validate "$$dir" 2>&1); \
		if [ $$? -eq 0 ]; then \
			echo "OK"; \
		else \
			echo "FAIL"; \
			echo "$$output" | sed 's/^/    /'; \
			failed=1; \
		fi; \
	done; \
	if [ $$failed -eq 1 ]; then \
		echo ""; \
		echo "Validation failed."; \
		exit 1; \
	fi
	@echo ""

## Check formatting of all .alloy files (alloy fmt -t)
fmt-check: check-alloy
	@echo "=== Checking formatting ==="
	@failed=0; \
	for f in $(ALLOY_FILES); do \
		$(ALLOY) fmt -t "$$f" > /dev/null 2>&1; \
		if [ $$? -ne 0 ]; then \
			echo "  needs formatting: $$f"; \
			failed=1; \
		fi; \
	done; \
	if [ $$failed -eq 1 ]; then \
		echo ""; \
		echo "Run 'make fmt' to fix formatting."; \
		exit 1; \
	else \
		echo "  All files formatted correctly."; \
	fi
	@echo ""

## Auto-format all .alloy files in place
fmt: check-alloy
	@echo "=== Formatting .alloy files ==="
	@for f in $(ALLOY_FILES); do \
		$(ALLOY) fmt -w "$$f"; \
	done
	@echo "  Done."

## Verify alloy CLI is installed
check-alloy:
ifndef ALLOY
	$(error alloy CLI not found. Install with: brew install grafana-alloy)
endif

## Show this help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /' | paste - <(grep -E '^[a-z].*:' $(MAKEFILE_LIST) | sed 's/:.*//') | awk -F'\t' '{printf "  %-14s %s\n", $$2, $$1}'
