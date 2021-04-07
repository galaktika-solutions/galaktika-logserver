# `.env`

```env
# Needed for compose
COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
REGISTRY_URL=vertis-docker-registry:5000
COMPOSE_PROJECT_NAME=vertis-logserver
VERSION=latest

DEV_MODE=True

EMAIL_HOST=mail.vertis.com
EMAIL_PORT=25
EMAIL_FROM=gabor.egyed@vertis.com
EMAIL_RECIPIENT=gabor.egyed@vertis.com

BACKUP_UID=1000
BACKUP_RETENTION_DAYS= 40
DEBUG_FILES_BACKUP_RETENTION_DAYS= 3

CURATOR_SERVICE=True
CURATOR_CRON=0 55 17 * * * Europe/Budapest

GF_SMTP_ENABLED=true
GF_SMTP_HOST=mail.vertis.com:25
GF_SMTP_FROM_ADDRESS=grafana@vertis.com
GF_SMTP_SKIP_VERIFY=true
GF_SMTP_STARTTLS_POLICY=MandatoryStartTLS
```

DEV mode you could create a developer certificate and ca

```sh
make certificate
```

`..env-files`

```env
ca.crt
ca.key
certificate.crt
certificate.key
certificate.pem
```
