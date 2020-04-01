APP_NAME=martinjuul/sonarqube

build:
	docker build --tag ${APP_NAME} .

build-nc:
	docker build --force-rm --tag ${APP_NAME} .