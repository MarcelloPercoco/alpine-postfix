ARG ALPINE_VERSION=3.20

FROM alpine:${ALPINE_VERSION}

LABEL MAINTAINER="Marcello Percoco <114474556+MarcelloPercoco@users.noreply.github.com>"
LABEL org.opencontainers.image.source=https://github.com/MarcelloPercoco/alpine-postfix
LABEL org.opencontainers.image.description="Simple Postfix container"

HEALTHCHECK CMD nc -z 127.0.0.1 25

RUN apk update \
	&& apk upgrade --no-cache \
	&& apk add --no-cache bash postfix postfix-pcre cyrus-sasl

COPY conf /etc/postfix

VOLUME ["/var/spool/postfix"]

ENTRYPOINT ["/etc/postfix/postfix-service.sh"]

EXPOSE 25
