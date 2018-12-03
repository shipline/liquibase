FROM alpine:3.8

# Copy from openjdk/8/jdk/alpine/Dockerfile

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u181
ENV JAVA_ALPINE_VERSION 8.181.13-r0

RUN set -x \
    && apk add --no-cache \
        openjdk8="$JAVA_ALPINE_VERSION" \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN apk --no-cache add --virtual .build-dependencies curl tar gzip

RUN curl -LO https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.6.2/liquibase-3.6.2-bin.tar.gz
RUN mkdir liquibase-3.6.2-bin \
    && mkdir /opt \
    && tar -xvzf liquibase-3.6.2-bin.tar.gz -C liquibase-3.6.2-bin \
    && rm -f liquibase-3.6.2-bin.tar.gz \
    && mv liquibase-3.6.2-bin /opt/liquibase \
    && chmod +x /opt/liquibase/liquibase \
    && ln -s /opt/liquibase/liquibase /usr/local/bin/

RUN apk del .build-dependencies
RUN liquibase --version
