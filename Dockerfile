FROM alpine:latest
LABEL MAINTAINER="Marcello Percoco <marcello.percoco@gmail.com>"

RUN apk add --no-cache bash postfix postfix-pcre 

COPY conf /etc/postfix

VOLUME ["/var/spool/postfix"]
VOLUME ["/etc/postfix"]

ENTRYPOINT ["/etc/postfix/postfix-service.sh"]

EXPOSE 25
