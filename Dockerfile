ARG ALPINE_VERSION=3.24
FROM alpine:${ALPINE_VERSION}

# Install Postfix and security updates
RUN apk upgrade --no-cache && \
    apk add --no-cache cyrus-sasl netcat-openbsd postfix postfix-pcre

# Healthcheck checking if SMTP port is responding
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD nc -z 127.0.0.1 25 || exit 1

COPY conf /etc/postfix
# Ensure the entrypoint script is executable
RUN chmod +x /etc/postfix/postfix-service.sh

VOLUME ["/var/spool/postfix"]

EXPOSE 25

ENTRYPOINT ["/etc/postfix/postfix-service.sh"]
