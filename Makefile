.DEFAULT_GOAL := help
SHELL := /bin/bash

ROOT_DIR = $(realpath .)
TERRAFORM_DIR = ${ROOT_DIR}/terraform
TERRAFORM_OUTPUT = ${TERRAFORM_DIR}/output.json
SSH_KEY = ${ROOT_DIR}/ssh_key_id_rsa
SSH_PUB_KEY = ${SSH_KEY}.pub
OS_IMAGE = ${TERRAFORM_DIR}/ubuntu-20.04-server-cloudimg-amd64.ova
CLUSTER_NAME = kubeone
CONFIG_FILE = kubeone.yaml
CREDENTIALS_FILE = credentials.yaml
KUBECONFIG_FILE = kubeconfig

# ======================================================================================================================
.PHONY: help
## help: prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
# ======================================================================================================================

# ======================================================================================================================
.PHONY: check-env
## check-env: verifies current working environment meets all requirements
check-env:
	which terraform
	which kubeone
	test -f "${OS_IMAGE}" || curl -s https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova > "${OS_IMAGE}"
	test -f "${SSH_KEY}" || ssh-keygen -t rsa -b 4096 -f "${SSH_KEY}" -N ''
	chmod 640 "${SSH_PUB_KEY}" && chmod 600 "${SSH_KEY}"
	ssh-add "${SSH_KEY}" || true
	kubeone version > ${ROOT_DIR}/kubeone.version.json
	test -f "${TERRAFORM_DIR}/main.tf" || kubeone init --provider vmware-cloud-director --terraform --path ${TERRAFORM_DIR} --cluster-name ${CLUSTER_NAME} -c ${CREDENTIALS_FILE}
# ======================================================================================================================

# ======================================================================================================================
.PHONY: terraform
## terraform: provision all infrastructure
terraform: check-env terraform-init terraform-apply terraform-output

.PHONY: terraform-init
## terraform-init: initialize terraform
terraform-init:
	cd ${TERRAFORM_DIR} && terraform init

.PHONY: terraform-check
## terraform-check: validate terraform configuration and show plan
terraform-check:
	cd ${TERRAFORM_DIR} && \
		terraform validate && \
		terraform plan

.PHONY: terraform-apply
## terraform-apply: apply terraform configuration and provision infrastructure
terraform-apply:
	cd ${TERRAFORM_DIR} && \
		terraform apply -auto-approve

.PHONY: terraform-refresh
## terraform-refresh: refresh and view terraform state
terraform-refresh:
	cd ${TERRAFORM_DIR} && \
		terraform refresh

.PHONY: terraform-output
## terraform-output: output terraform information into file for KubeOne
terraform-output:
	cd ${TERRAFORM_DIR} && \
		terraform output -json > ${TERRAFORM_OUTPUT}

.PHONY: terraform-destroy
## kterraform-destroy: delete and cleanup infrastructure
terraform-destroy:
	cd ${TERRAFORM_DIR} && \
		terraform destroy
# ======================================================================================================================

# ======================================================================================================================
.PHONY: kubeone
## kubeone: run all KubeOne / Kubernetes provisioning steps
kubeone: check-env kubeone-apply kubeone-kubeconfig kubeone-generate-md kubeone-apply-md

.PHONY: kubeone-apply
## kubeone-apply: run KubeOne to deploy kubernetes
kubeone-apply:
	kubeone apply -c ${CREDENTIALS_FILE} -m ${CONFIG_FILE} -t ${TERRAFORM_OUTPUT} --verbose # --create-machine-deployments # --upgrade-machine-deployments

.PHONY: kubeone-kubeconfig
## kubeone-kubeconfig: write kubeconfig file
kubeone-kubeconfig:
	kubeone kubeconfig -c ${CREDENTIALS_FILE} -m ${CONFIG_FILE} -t ${TERRAFORM_OUTPUT} > ${KUBECONFIG_FILE}
	chmod 640 ${KUBECONFIG_FILE}

.PHONY: kubeone-generate-md
## kubeone-generate-md: generate a machinedeployments manifest for the cluster
kubeone-generate-md:
	kubeone config machinedeployments -m ${CONFIG_FILE} -t ${TERRAFORM_OUTPUT} > ${ROOT_DIR}/machines/${CLUSTER_NAME}-worker-pool.yml

.PHONY: kubeone-apply-md
## kubeone-apply-md: apply machinedeployments to the cluster
kubeone-apply-md:
	kubectl apply --kubeconfig ${KUBECONFIG_FILE} -f ${ROOT_DIR}/machines

.PHONY: kubeone-addons
## kubeone-addons: list KubeOne addons
kubeone-addons:
	kubeone addons list -c ${CREDENTIALS_FILE} -m ${CONFIG_FILE} -t ${TERRAFORM_OUTPUT}
# ======================================================================================================================
