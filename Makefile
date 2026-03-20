.PHONY: init plan apply destroy fmt validate

ENV ?= prod

init:
	cd envs/$(ENV) && terraform init

plan:
	cd envs/$(ENV) && terraform plan -var-file=terraform.tfvars

apply:
	cd envs/$(ENV) && terraform apply -var-file=terraform.tfvars

destroy:
	cd envs/$(ENV) && terraform destroy -var-file=terraform.tfvars

fmt:
	terraform fmt -recursive

validate:
	cd envs/$(ENV) && terraform validate
