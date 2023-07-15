TERRAFORM_LINT := $(shell command -v terraform-lexicographical-lint 2>/dev/null)

lint:
ifndef TERRAFORM_LINT
	$(error "terraform-lexicographical-lint not found or $$GOBIN not in $$PATH. Install with: go install github.com/shanet/terraform-lexicographical-lint@latest")
endif

	terraform fmt --recursive terraform
	terraform-lexicographical-lint terraform
