# Neo4J 3.1 with endpoints for purge, backup and restore

## Endpoint hooks 

### Backup and purge

Currently Neo4j has been enhanced with a purge-db endpoint which will automatically backup and then remove the existing graph database. It will keep up to four oldest copy of the database. 
This endpoint can be accessed by: 
  ```
  curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/purge-db
  ```
where the secret key is defined in the environment variable `WEBHOOK_SECRET` in the image. This allows the flexibility to prevent certain users from purging the data if needed (though it is currently not used). 
The default port for the hook endpoint is 9000. 

### Restore last backup

Neo4j has also been enhanced with a restore-db endpoint which will automatically restore the last backup database if available. This endpoint can be accessed by: 
  ```
  curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/restore-db
  ```

### Restore i-th backup

The i-th last previous backup can be restored by specifying it as a parameter to the endpoint, where i=0 refers to the last backup, and i=1 referring to the second last backup, and so on:
  ```
  curl -H "Content-type: text" --data "username" -H "X-Hub-Signature: username-hashed-with-sha256-and-secret-key" neo4jserver:hookport/hooks/restore-db?i=1
  ```
will restore the second last backup

### Usage examples

For example, for the user `neo4j`, with the default secret key, the endpoints can be accessed by:
  ```
  curl -H "Content-type: text" --data "neo4j" -H "X-Hub-Signature: c01387bf51848c8aba5a51dd188da5ff46ff5f4317d24e3922449fe0e74cce93" neo4jserver:hookport/hooks/purge-db
  ```
and 
  ```
  curl -H "Content-type: text" --data "neo4j" -H "X-Hub-Signature: c01387bf51848c8aba5a51dd188da5ff46ff5f4317d24e3922449fe0e74cce93" neo4jserver:hookport/hooks/restore-db
  ```

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
 
