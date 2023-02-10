SHELL := /bin/bash
VERSION := 0.14.11
UNAME := $(shell uname -s)

##==================================================================================================
##@ Helper

help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: \033[36m\033[0m\n"} /^[a-zA-Z\.\%-]+:.*?##/ { printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help

####==================================================================================================
##@ General initialization

install-dotenv:  ## Install dotenv to read .env file
ifeq ($(shell echo $$SHELL), /bin/bash)
	curl -sfL https://direnv.net/install.sh | bash
	echo $(shell echo 'eval "$$(direnv hook bash)"') >> ~/.bashrc
endif

.ONESHELL:
poetry-linux-fix:  ## Fix poetry on Linux
ifeq ($(UNAME), Linux)
	path=$(shell python -c "import keyring.util.platform_; print(keyring.util.platform_.config_root())")
	mkdir -p $$path
	cat <<- EOF > $$path/keyringrc.cfg
		[backend]
		default-keyring=keyring.backends.fail.Keyring
	EOF
endif

##==================================================================================================
##@ Repo initialization

repo-deps:  ## Install dependencies
	pip install poetry
	poetry config virtualenvs.in-project true
	poetry install

repo-pre-commit:  ## Install pre-commit
	poetry run pre-commit install
	poetry run pre-commit install -t commit-msg

repo-env:  ## Configure environment variables
	cat .test.env  > .env
	echo "dotenv" > .envrc

repo-init: repo-deps repo-pre-commit repo-env  ## Initialize repository by executing above commands

##==================================================================================================
##@ AWS

.ONESHELL:
aws-instance-connect:  ## Connect to EC2 (e.g. make aws-instance-connect INSTANCE_USER_NAME=ubuntu)
	public_ip=$(shell cd terraform && terraform output -raw instance_public_ip)
	user_name=${INSTANCE_USER_NAME}
	ssh -i terraform/ssh/deep-learning-for-audio.pem $$user_name@$$public_ip

aws-datasets-pull:  ## Pull some datasets from S3 bucket
	poetry run dvc pull

##==================================================================================================
##@ Docker

docker-build:  ## Build container
	docker build -t deep-learning-for-audio .

docker-run:  ## Run container
	docker run -dte WANDB_API_KEY=${WANDB_API_KEY} deep-learning-for-audio

##==================================================================================================
##@ Datasets

datasets-rights: ## Grant execution rights to scripts/datasets.sh
	chmod +x ./scripts/datasets.sh

datasets-lj: datasets-rights ## Download LJSpeech dataset
	sh ./scripts/datasets.sh download_lj_speech \
		resources/datasets/asr \
		https://data.keithito.com/data/speech/LJSpeech-1.1.tar.bz2

.ONESHELL:
datasets-libri.%: datasets-rights  ## Download specified LibriSpeech dataset (e.g. make datasets-libri.dev-clean)
	dataset=$(shell echo $@ | awk -F. '{print $$2}')
	sh ./scripts/datasets.sh download_libri_speech \
		resources/datasets/asr \
		$$dataset

.ONESHELL:
datasets-libri.all: datasets-rights  ## Download all LibriSpeech datasets
	for dataset in dev-clean \
				   dev-other \
				   test-clean \
				   test-other \
				   train-clean-100 \
				   train-clean-360 \
				   train-other-500
	do
		sh ./scripts/datasets.sh download_libri_speech \
			resources/datasets/asr \
			$$dataset
	done

##==================================================================================================
##@ Research

jupyter: ## Run jupyter lab
	poetry run jupyter lab

##==================================================================================================
##@ Checks

mypy: ## Run type checker
	poetry run mypy

##==================================================================================================
##@ Secrets

gen-secrets-baseline:  ## Create .secrets.baseline file
	poetry run detect-secrets scan > .secrets.baseline

##==================================================================================================
##@ Cleaning

clean-logs: ## Delete log files
	rm -rf logs/* wandb/*

clean-general: ## Delete general files
	find . -type f -name "*.DS_Store" -ls -delete
	find . | grep -E "(__pycache__|\.pyc|\.pyo)" | xargs rm -rf
	find . | grep -E ".pytest_cache" | xargs rm -rf
	find . | grep -E ".ipynb_checkpoints" | xargs rm -rf
	find . | grep -E ".trash" | xargs rm -rf
	rm -f .coverage

clean-all: clean-logs clean-general ## Delete all "junk" files

##==================================================================================================
##@ Miscellaneous

upd-pre-commit:  ## Update pre-commit hooks
	poetry run pre-commit autoupdate
