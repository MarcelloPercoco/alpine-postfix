# docker-postfix-relay

A lightweight Postfix relay server based on Alpine Linux, designed to forward emails from local services to an upstream SMTP server.

## 🚀 Key Features

* **Dynamic Config**: Placeholders like `{{ DOMAIN }}` in configuration files are automatically replaced by environment variables at runtime.
* **Header Privacy**: Strips internal IP addresses and User-Agent headers from outgoing mail for better privacy.
* **Custom Overrides**: Support for custom `.cf` settings and `.map` files via the `/overrides` volume.

## 🛠 Usage

### Docker Compose
```yaml
services:
  postfix:
    image: cobra1978/postfix-relay:latest
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

## ⚙️ Configuration Variables

The following environment variables are used to dynamically configure Postfix at runtime:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `DOMAIN` | `localdomain` | [cite_start]Sets the `mydomain` and `myorigin` variables[cite: 20]. |
| `HOSTNAME` | `localhost` | [cite_start]Sets the `myhostname` variable[cite: 20]. |
| `MESSAGE_SIZE_LIMIT` | `50000000` | [cite_start]Defines the maximum size of a message in bytes[cite: 20]. |
| `RELAYNETS` | (empty) | [cite_start]Networks allowed to relay mail through this server (added to `mynetworks`)[cite: 20]. |
| `RELAYHOST` | (empty) | [cite_start]The upstream SMTP server where all mail will be forwarded[cite: 20]. |
| `THEME` | `theme-dark` | (Optional) Theme for dashboard integration if applicable. |

## 📂 Custom Overrides

You can further customize Postfix by mounting a volume to `/overrides`. The `postfix-service.sh` script handles these files as follows:

* **`postfix.cf`**: Any valid Postfix configuration line in this file will be applied using `postconf -e` during startup.
* **`*.map` files**: Any file ending in `.map` (e.g., `transport.map`, `virtual.map`) will be copied to `/etc/postfix`, processed with `postmap` to create the `.db` index, and then the source `.map` will be removed for security.
* **Permissions**: The script automatically sets `root:root` ownership and `0600` permissions on the generated `.db` files.
