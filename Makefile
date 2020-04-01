APP_NAME=martinjuul/sonarqube

build-nc:
	docker build --tag ${APP_NAME} .