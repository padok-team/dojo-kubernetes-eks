all: help

##@ Docs Generation
doc: README.md ## Generates Terraform docs for modules
	$(call info_colors,blue,📄 Terraform docs)
	@terraform-docs .

##@ Formating
format: ## Runs Terraform fmt and Validate
	terraform init
	terraform fmt
	terraform validate

include prettier.mk

.PHONY: all doc format
