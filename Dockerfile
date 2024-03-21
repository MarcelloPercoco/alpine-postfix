FROM alpine:latest
LABEL MAINTAINER="Marcello Percoco <marcello.percoco@gmail.com>"

RUN apk add --no-cache bash postfix postfix-pcre 

COPY conf /etc/postfix
COPY scripts /

VOLUME ["/var/spool/postfix"]
VOLUME ["/etc/postfix"]

ENTRYPOINT ["/postfix-service.sh"]

EXPOSE 25
