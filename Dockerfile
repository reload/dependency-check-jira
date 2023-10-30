FROM composer:2.6.5@sha256:fb3c5a283f2dc08e08841048498e8a82c3864648c84255b5ad7243b38d33a8db AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:8.4.2 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.2.12-alpine3.18@sha256:403361a17e469f6069eef76a1ed1b55cc891aece27f934af9285e78b1f225938

ENV JAVA_HOME /opt/openjdk-17
ENV PATH $JAVA_HOME/bin:$PATH

COPY --from=jdk ${JAVA_HOME} ${JAVA_HOME}

RUN set -eux; \
        java -Xshare:dump; \
        java --version;

COPY --from=dependency-check /usr/share/dependency-check /opt/dependency-check

COPY --from=build-env /opt/dependency-check-jira /opt/dependency-check-jira

ENTRYPOINT ["/opt/dependency-check-jira/bin/checkdep"]
CMD []
