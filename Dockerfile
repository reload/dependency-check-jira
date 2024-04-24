FROM composer:2.7.4@sha256:ee4676ef56f97c82f11b421717386bcf9353a53bee9276c414ad80a0a4dc0e02 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:9.1.0 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.3.6-alpine3.18@sha256:a2d3001213e2a4c5bd411ae187c9e2c7de2b929aa884bfadf0b5a400cfbd52b4

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
