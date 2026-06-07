# alpine-postfix

A lightweight, secure, and minimal Postfix relay server based on Alpine Linux. Designed to forward emails from local services or networks to an upstream SMTP server (like Gmail, Sendgrid, or your own mail server).

## 🚀 Key Features

* **Lightweight & Secure**: Built on the minimal Alpine Linux (3.23) with Cyrus SASL and PCRE support.
* **Dynamic Configuration**: Automatically replaces placeholders like `{{ DOMAIN }}` with environment variables at runtime.
* **Privacy-focused**: Automatically strips internal IP addresses and User-Agent headers from outgoing mail to prevent information leakage.
* **Custom Overrides**: Easily inject custom Postfix configuration directives (`postfix.cf`) and `.map` files (e.g., transport, virtual) via the `/overrides` volume.
* **Health Checks**: Built-in health check to monitor the SMTP daemon's status.

---

## 🛠 Usage

### Docker Compose

```yaml
services:
  postfix:
    image: ghcr.io/marcellopercoco/alpine-postfix:latest
    container_name: alpine-postfix
    environment:
      - DOMAIN=example.com
      - HOSTNAME=mail
      - RELAYHOST=[smtp.provider.com]:587
      - RELAYNETS=172.16.0.0/12
      - MESSAGE_SIZE_LIMIT=52428800
    volumes:
      - ./overrides:/overrides
    ports:
      - "25:25"
    restart: always
```

---

## ⚙️ Configuration Variables

The entrypoint script uses the following environment variables to dynamically configure Postfix:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `DOMAIN` | `localdomain` | Sets the `mydomain` and `myorigin` variables. |
| `HOSTNAME` | `localhost` | Sets the `myhostname` variable. If it does not contain a dot `.`, it is automatically set to `HOSTNAME.DOMAIN`. |
| `MESSAGE_SIZE_LIMIT` | `50000000` | Defines the maximum size of a message in bytes (defaults to ~50MB). |
| `RELAYNETS` | (empty) | Comma/space-separated list of IP networks allowed to relay mail through this server. |
| `RELAYHOST` | (empty) | The upstream SMTP server where all mail will be forwarded (e.g. `[smtp.sendgrid.net]:587`). |

---

## 📂 Custom Overrides

You can further customize Postfix settings by mounting a folder to `/overrides` containing any of the following:

### 1. `postfix.cf`
Any valid Postfix configuration line in this file will be parsed and applied using `postconf -e` at startup.
*Lines starting with `#` or empty lines are ignored.*

**Example `/overrides/postfix.cf`:**
```ini
# Increase transport connect timeout
smtp_connect_timeout = 60s
# Use custom banner
smtpd_banner = $myhostname ESMTP
```

### 2. `*.map` files
Any file ending in `.map` (e.g., `transport.map`, `virtual.map`) will be:
1. Copied to `/etc/postfix/`
2. Processed automatically with `postmap` to generate the matching lookup database
3. Securely cleaned up (the source `.map` is deleted, leaving only the `.db` files with `root:root` and `0600` permissions)
