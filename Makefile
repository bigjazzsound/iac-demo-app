init:
	terraform init

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan

verify:
	@curl $(shell terraform output -raw endpoint)

destroy:
	terraform plan -out=tfplan -destroy
