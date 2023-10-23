FROM composer:2.6.5@sha256:403855481b9b080ee79c29b301b8d1817b7ad183d477dd2c1de243831a9256d3 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:8.4.0 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.2.11-alpine3.18@sha256:36a956d9e6ef3b47787c002737c5b1c8cd1147731b7f537f4c22faf77a4fd174

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
