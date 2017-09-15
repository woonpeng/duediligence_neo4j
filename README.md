# Neo4J 3.1 with endpoints for purge, backup, restore, and cleanup

## Ansible deployment

The file `authorized_keys` contains the public key needed by Ansible to deploy into the Neo4j image. This file is copied from the `finnet-deploy` repository. See https://github.com/datagovsg/finnet-deploy/blob/neo4j-ssh/vars/keys/neo4j_staging.pub for more information

## Endpoint hooks

**Note:** The interface has changed from a webhook to providing SSH access to call the scripts

The default port for SSH access is `9000`. Access to the Neo4j is controlled via using the appropriate SSH keys, and providing access via the user running the neo4j service (which is `root` in the docker image and `neo4j` in a normal server setup). This setting up of SSH keys have to be done manually. A script `insert_ssh_keys.sh` has been provided to make it easier. Invoke `insert_ssh_keys -h` for more information.

### Backup

Backup the existing graph database. This is done by SSH-ing into the Neo4j server and calling the script `backup.sh name` where `name` is an optional parameter to name the backup file. If `name` is not provided, the endpoint will use database system's current date.

```bash
ssh $neo4jserver -p $hookport "backup.sh backup-filename"
```

### Purge

Remove the existing graph database. This is done by SSH-ing into the Neo4j server and calling the script `purge.sh`.

```bash
ssh $neo4jserver -p $hookport "purge.sh"
```

### Restore

Restore the graph database from a backup file. This is done by SSH-ing into the Neo4j server and calling the script `restore.sh name` where `name` is an optional parameter to specify the backup file to restore from. If `name` is not provided, the endpoint will use the latest backup file based on the modified date.

```bash
ssh $neo4jserver -p $hookport "restore.sh backup-filename"
```

### Cleanup

Remove backup files older than 30 days. This is done by SSH-ing into the Neo4j server and calling the script `cleanup.sh`.

```bash
ssh $neo4jserver -p $hookport "cleanup.sh"
```


### Import

Import the graph database from a zip file consisting of csv files corresponding to the nodes and edges. This is done by first copying the zip file into the Neo4j server via SCP and then calling the script `builddb.sh name` where `name` is the full path to the zip file to restore from.

```bash
scp -P $hookport $importzipfile $neo4jserver:$filepath
ssh $neo4jserver -p $hookport "builddb.sh $filepath/$importzipfile"


## Packaging as a RPM

Running the script `build-packaging.sh` will build a RPM which can be installed in the host machine (with Neo4j installed) as a service.

To install the RPM on the host machine:
```
sudo rpm -i neo4j-webhook*.rpm
```
Neo4j has to be installed first before installing the custom addons.
