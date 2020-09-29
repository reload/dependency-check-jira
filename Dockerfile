FROM composer:1.10.13 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM openjdk:14-ea-15-jdk-alpine AS jdk

FROM php:7.4.10-alpine

ARG DEPENDENCY_CHECK_VERSION=6.0.2

ENV JAVA_HOME /opt/openjdk-14
ENV PATH $JAVA_HOME/bin:$PATH

COPY --from=jdk ${JAVA_HOME} ${JAVA_HOME}

RUN set -eux; \
        java -Xshare:dump; \
        java --version;

RUN cd /opt && \
        wget https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK_VERSION}/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
        unzip dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
        rm dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip

COPY --from=build-env /opt/dependency-check-jira /opt/dependency-check-jira

ENTRYPOINT ["/opt/dependency-check-jira/bin/checkdep"]
CMD []
