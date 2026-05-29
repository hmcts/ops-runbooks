.PHONY: jenkins-mermaid-pngs

JENKINS_MERMAID_DIR := source/jenkins/mermaid-diagrams
JENKINS_IMAGE_DIR := source/jenkins/images
MERMAID_DOCKER_IMAGE := ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:latest
MERMAID_WIDTH := 1920
MERMAID_HEIGHT := 1080

jenkins-mermaid-pngs:
	mkdir -p $(JENKINS_IMAGE_DIR)
	docker run --rm -u "$(shell id -u):$(shell id -g)" -v "$(PWD)/source/jenkins:/data" $(MERMAID_DOCKER_IMAGE) -i /data/mermaid-diagrams/cft-jenkins-agents-mis.mmd -o /data/images/cft-jenkins-agents-mis.png -w $(MERMAID_WIDTH) -H $(MERMAID_HEIGHT)
	docker run --rm -u "$(shell id -u):$(shell id -g)" -v "$(PWD)/source/jenkins:/data" $(MERMAID_DOCKER_IMAGE) -i /data/mermaid-diagrams/civil-jenkins-agents-mis.mmd -o /data/images/civil-jenkins-agents-mis.png -w $(MERMAID_WIDTH) -H $(MERMAID_HEIGHT)
	docker run --rm -u "$(shell id -u):$(shell id -g)" -v "$(PWD)/source/jenkins:/data" $(MERMAID_DOCKER_IMAGE) -i /data/mermaid-diagrams/sds-jenkins-agents-mis.mmd -o /data/images/sds-jenkins-agents-mis.png -w $(MERMAID_WIDTH) -H $(MERMAID_HEIGHT)
