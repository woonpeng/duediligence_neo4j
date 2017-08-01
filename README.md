# Neo4J 3.1 with endpoints for purge, backup, restore, and cleanup

## Endpoint hooks

The default port for the webhook is `9000`. The secret key is defined in the environment variable `WEBHOOK_SECRET` in the docker image. This provide some level of access control to restrict the use of these privilege operations to certain users.

### Backup

Backup the existing graph database. You can name the backup file using the URL parameter `name`. If `name` is not provided, the endpoint will use database system's current date.

```bash
curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/backup
```

### Purge

Remove the existing graph database.

```bash
curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/purge
```

### Restore

Restore the graph database from a backup file. You can provide the name of the backup file using the URL parameter `name`. If `name` is not provided, the endpoint will use the latest backup file based on the modified date.

```bash
curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/restore
```

### Cleanup

Remove backup files older than 30 days.

```bash
curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/cleanup
```

## Generating signature

In bash shell:
```bash
echo -n "username" | openssl dgst -sha256 -hmac $WEBHOOK_SECRET
```

In Python:
```python
import hashlib
import hmac
import os

hmac.new(key=os.environ['WEBHOOK_SECRET'], msg='username', digestmod=hashlib.sha256).hexdigest()
```

## Enabling secure mode 

By default, the webhook is started to serve the endpoints via http. In order to serve the endpoints via https, corresponding certificate and key files have to be provided by setting the environment variables `NEO4J_WEBHOOK_CERT` and 
`NEO4J_WEBHOOK_KEY` to point to the respective files. A self signed certificate can be generated via:

```
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem
```

## Packaging as a RPM

Running the script `build-packaging.sh` will build a RPM which can be installed in the host machine (with Neo4j installed) as a service. 

To install the RPM on the host machine: 
```
sudo rpm -i neo4j-webhook*.rpm
```
Neo4j has to be installed first before installing the webhook

The secret key, certificate and key files can be configured via: 
```
sudo configure-neo4j-webhook [...]
```

