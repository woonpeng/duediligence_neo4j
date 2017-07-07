# Neo4J 3.1.3 with endpoints for purge, backup and restore

## Endpoint hooks 

Currently Neo4j has been enhanced with a purge-db endpoint which will automatically backup and then remove the existing graph database. It will keep up to four oldest copy of the database. 
This endpoint can be accessed by: 
  ```
  curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/purge-db
  ```
where the secret key is defined in the environment variable `WEBHOOK_SECRET` in the image. This allows the flexibility to prevent certain users from purging the data if needed (though it is currently not used). 
The default port for the hook endpoint is 9000. 

### Generating signature

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

## Staging

On staging, you should use `docker-compose.yml` and `docker-compose.staging.yml` in this order
to run the container.

```bash
sudo docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```
