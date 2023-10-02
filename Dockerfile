FROM composer:2.6.3@sha256:1ac7a547cb88acb0de62663b70f2b3d80ad27355288245159404b6ae40cd9ca3 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:8.4.0 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.2.11-alpine3.18@sha256:671c309315113b73eba316bb175e130f376d3ba5e1a930794909ef5a1cb10fbc

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
