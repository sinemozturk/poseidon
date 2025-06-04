# Detect OS and set DOCKER command appropriately
OS := $(shell uname -s)
ifeq ($(OS), Darwin)
	DOCKER := docker
else
	DOCKER := sudo docker
endif

APP_NAME ?= poseidon-app

.PHONY: all docker package appbundle clean

all: docker package appbundle

docker:
	$(DOCKER) build -t $(APP_NAME):latest .

package:
	$(DOCKER) save $(APP_NAME):latest | gzip > $(APP_NAME).tar.gz

appbundle:
	@echo "Cleaning old dist and tarballs..."
	@rm -f dist/$(APP_NAME).tar.gz
	@rm -f $(APP_NAME).tar.gz
	@rm -rf dist
	@echo "Creating dist/$(APP_NAME)..."
	@mkdir -p dist/$(APP_NAME)/images dist/$(APP_NAME)/charts

	@echo "Copying Ansible roles/actions and appbundle..."
	@cp -r bundles/$(APP_NAME)/roles dist/$(APP_NAME)/
	@cp -r bundles/$(APP_NAME)/actions dist/$(APP_NAME)/
	@cp bundles/$(APP_NAME)/appbundle.yml dist/$(APP_NAME)/

	@echo "Building Docker image..."
	@$(MAKE) docker

	@echo "Saving Docker image..."
	@$(DOCKER) save $(APP_NAME):latest | gzip > dist/$(APP_NAME)/images/$(APP_NAME).tar.gz

	@echo "Packaging Helm chart..."
	@helm package bundles/$(APP_NAME)/charts
	@mv $(APP_NAME)-*.tgz dist/$(APP_NAME)/charts/

	@echo "Creating ansible.cfg..."
	@echo "[defaults]" > dist/$(APP_NAME)/ansible.cfg
	@echo "roles_path = roles" >> dist/$(APP_NAME)/ansible.cfg
	@echo "playbook_dir = actions" >> dist/$(APP_NAME)/ansible.cfg

	@echo "Creating final appbundle tarball..."
	@cd dist/$(APP_NAME) && tar czf ../$(APP_NAME).tar.gz .

	@echo "✅ Appbundle created: dist/$(APP_NAME).tar.gz"

clean:
	@rm -f $(APP_NAME).tar.gz
	@rm -rf dist
