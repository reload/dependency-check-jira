FROM composer:2.6.6@sha256:4c1d9cef880bb49d99bf9dc2b13440c37d5b16a31395289282ae3c5f79bf48ef AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:9.0.4 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.3.0-alpine3.18@sha256:72ce7e0cf01d9325c30f1d5c4a588fa794c2e1620dd7c087f5a682cc9c27ff39

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
