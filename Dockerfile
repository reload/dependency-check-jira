FROM composer:1.9 AS build-env

COPY . /opt/dependency-check-jira

WORKDIR /opt/dependency-check-jira

RUN composer install --prefer-dist --no-dev

FROM php:7.4.2-alpine

ARG DEPENDENCY_CHECK_VERSION=5.2.4

ENV JAVA_HOME /opt/openjdk-14
ENV PATH $JAVA_HOME/bin:$PATH

# Java setup taken from the official image:
# https://github.com/docker-library/openjdk/blob/61a91d560d2637de14c5f7a96ded6d1b5b06ee0b/14/jdk/alpine/Dockerfile
ENV JAVA_VERSION 14-ea+15
ENV JAVA_URL https://download.java.net/java/early_access/alpine/15/binaries/openjdk-14-ea+15_linux-x64-musl_bin.tar.gz
ENV JAVA_SHA256 76091da1b6ed29788f0cf85454d23900a4134286e5feb571247e5861f618d3cd
# "For Alpine Linux, builds are produced on a reduced schedule and may not be in sync with the other platforms."

RUN set -eux; \
	\
	wget -O /openjdk.tgz "$JAVA_URL"; \
	echo "$JAVA_SHA256 */openjdk.tgz" | sha256sum -c -; \
	mkdir -p "$JAVA_HOME"; \
	tar --extract --file /openjdk.tgz --directory "$JAVA_HOME" --strip-components 1; \
        rm /openjdk.tgz; \
        java -Xshare:dump; \
        java --version;

RUN cd /opt && \
        wget https://dl.bintray.com/jeremy-long/owasp/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
        unzip dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
        rm dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip

COPY --from=build-env /opt/dependency-check-jira /opt/dependency-check-jira

ENTRYPOINT ["/opt/dependency-check-jira/bin/checkdep"]
CMD []
