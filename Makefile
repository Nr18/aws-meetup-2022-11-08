SHELL = /bin/bash -c
VIRTUAL_ENV = $(shell poetry env info -p)
export BASH_ENV=$(VIRTUAL_ENV)/bin/activate

SKIP_TEST=0

.DEFAULT_GOAL:=help
.PHONY: help
help:  ## Display this help
	$(info How do you know you are compliant? AWS Config will tell you when you deployed your infrastructure! Isn't it better to prevent non-compliant resources to be deployed in the first place? Let's see how we can use preventive and detective tools together.)
	awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

pyproject.toml:
	$(info Create pyproject.toml file...)
	poetry init \
		--no-interaction --quiet \
		--name "aws-meetup-2022-11-08" \
		--description "How do you know you are compliant? AWS Config will tell you when you deployed your infrastructure! Isn't it better to prevent non-compliant resources to be deployed in the first place? Let's see how we can use preventive and detective tools together." \
		--license=MIT \
		--python ^3.9 \
		--dependency aws-sam-cli \
		--dependency aws-cfn-update \
		--dependency cfn-guard-test
	sed -i '' 's/$(shell echo "aws-meetup-2022-11-08" | tr "-" _)/src/g' pyproject.toml

.git:
	git init
	pre-commit install

.PHONY: install
install: pyproject.toml .git ## Install all dependencies
	poetry install

.aws-sam/build/template.yaml: build

reports:
	mkdir reports

.PHONY: test
test: cfn-guard-test cfn-guard ## Run the tests defined in the project

.PHONY: cfn-guard-test
cfn-guard-test: reports
	$(info Running cfn-guard tests)
	cfn-guard-test --rules-path ./src/rules --test-path ./tests/rules --junit-path ./reports/cfn-guard.xml

.PHONY: cfn-guard
cfn-guard:
	$(info Running cfn-guard)
	if [ $(SKIP_TEST) == 0 ]; then\
		cfn-guard validate --rules ./src/rules --data template.yml; \
	fi

.PHONY: build
build: test ## Build the artifacts needed for the deployment
	$(info Building artifacts)
	sam build
	aws-cfn-update config-rule-inline-code --resource S3BucketRule --file ./src/rules/S3Bucket.guard ./.aws-sam/build/template.yaml

.PHONY: deploy
deploy: .aws-sam/build/template.yaml ## Deploy the template to AWS
	$(info Deploy template)
	sam deploy --resolve-s3 --no-fail-on-empty-changeset

.PHONY: destroy
destroy: ## Destroy the deployed resources from your AWS account
	sam delete

.PHONY: clean
clean: ## Cleanup, removes the virtual environment
	$(info Remove virtual environment $(VIRTUAL_ENV))
	[[ -d "$(VIRTUAL_ENV)" ]] && rm -rf "$(VIRTUAL_ENV)" || True
	[[ -d "reports" ]] && rm -rf "reports" || True
	[[ -d ".aws-sam" ]] && rm -rf ".aws-sam" || True

$(VERBOSE).SILENT:
