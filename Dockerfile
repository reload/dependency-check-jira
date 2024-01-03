FROM composer:2.6.6@sha256:1f88162f6d30fe394990edd298f181f66e8a4ba36d3e102213c2d4a8eb8654a5 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:9.0.7 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.3.1-alpine3.18@sha256:87cd6345439dcd87a936a9483111859b81bc418cdbb0dc14e9fff448037480ff

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
