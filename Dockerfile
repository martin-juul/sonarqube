# SonarSource did not make official Docker images for SonarQube 7.1 and above (as of 2018-11-20)
# Based on https://github.com/SonarSource/docker-sonarqube/blob/5d738964cc4b857ca5b399d6f0bb626b6710bac6/7.1/Dockerfile

# 7.9.3 required jdk 11
FROM openjdk:11

ENV SONAR_VERSION=7.9.3 \
    SONARQUBE_HOME=/opt/sonarqube \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=""

LABEL org.label-schema.name="sonarqube" \
      org.label-schema.vcs-url="https://github.com/martin-juul/sonarqube" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Martin Juul <code@juul.xyz>"

RUN set -xe \
    && groupadd -r sonarqube \
    && useradd -r -g sonarqube sonarqube

# grab gosu for easy step-down from root
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 0x036a9c25bf357dd4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 0xcfca4a29d26468de \
    && cd /opt \
    && curl -o sonarqube.zip -fSL https://binaries.sonarsource.com/CommercialDistribution/sonarqube-developer/sonarqube-developer-$SONAR_VERSION.zip \
    && curl -o sonarqube.zip.asc -fSL https://binaries.sonarsource.com/CommercialDistribution/sonarqube-developer/sonarqube-developer-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:sonarqube sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
ENTRYPOINT ["./bin/run.sh"]

EXPOSE 9000