# `.env`

```env
# Needed for compose
REGISTRY_URL=vertis-docker-registry:5000
REGISTRY_NAME=vertis-logserver
REGISTRY_TAG=latest

COMPOSE_PROJECT_NAME=vertis-testlogserver
COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml

DEV_MODE=True

EMAIL_HOST=mail.vertis.com
EMAIL_PORT=25
EMAIL_FROM=dev@vertis.com
EMAIL_RECIPIENT=dev@vertis.com

CURATOR_SERVICE=True
os.environ.get('SECOND_LOGSERVER_RUN_ON_START') == 'True',

NETWORK_RANGE=10.5.9.0/24

ELASTIC_PORT=9200
KIBANA_PORT=5601
STUNNEL_PORT=9201
QS_FIREWALL_PORT=1000
VERTIS_FIREWALL_PORT=1001
SWITCH_PORT=1002
LOGSTASH_PORT=5044
```

```.env-files
ca.crt
ca.key
certificate.crt
certificate.key
certificate.pem
```
