FROM composer:2.7.2@sha256:63c0f08ca413700adcec721aa425e1247304c98314ed0bc2e5fc3699424e2364 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM owasp/dependency-check:9.0.10 AS dependency-check

FROM openjdk:17-ea-14-jdk-alpine AS jdk

FROM php:8.3.4-alpine3.18@sha256:9c334e1fa29715eb6640ee98233ff25130803dc975f187550990c5198c4f8cf3

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
