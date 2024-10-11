ARG ALPINE_VERSION=3.20

FROM alpine:${ALPINE_VERSION}
LABEL MAINTAINER="Marcello Percoco <marcello.percoco@gmail.com>"

RUN apk update \
	&& apk upgrade --no-cache

RUN apk add --no-cache bash postfix postfix-pcre cyrus-sasl

COPY conf /etc/postfix

VOLUME ["/var/spool/postfix"]

ENTRYPOINT ["/etc/postfix/postfix-service.sh"]

EXPOSE 25
