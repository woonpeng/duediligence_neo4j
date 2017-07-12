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
