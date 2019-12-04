# Neo4J 3.1 with endpoints for purge, backup, restore, and cleanup

## Ansible deployment

The file `authorized_keys` contains the public key needed by Ansible to deploy into the Neo4j image. This file is copied from the `finnet-deploy` repository. See https://github.com/datagovsg/finnet-deploy/blob/neo4j-ssh/vars/keys/neo4j_staging.pub for more information

## Setup

A sample docker-compose file is provided on setting up the neo4j server. Before starting the server, you would need to set up the ssh keys to allow the finnet services to connect to the neo4j server. 

### Setting up ssh keys

On another machine, you can set up a pair of ssh keys by:

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

and choosing to save your key pair files in the project folder as `id_rsa` (private key) and `id_rsa.pub` (public key).

Make use of the script `add_ssh_key.sh` to create an authorized_keys file for the neo4j server:

```
add_ssh_key.sh -n 1 -r ./id_rsa.pub
```

This will add the key with restrictions on what commands it can run on the neo4j server

### Mounting the authorized keys to neo4j server

This is specified in `docker-compose.yml` under the service `neo4j` under `volumes`. This is already set up in the example docker-compose file, but may be needed to be set up if you are setting up your own services. 

For an actual neo4j server that is not containerized, put the file in `neo4j-keys/authorized_keys` in the corresponding user's ssh folder, i.e. `~/.ssh/`. This user should be the same user as the one that is running the neo4j services. You should also export the environment into the file `~/.ssh/environment`. You can use `insert_ssh_key.ssh` script instead to do this

### Testing with a client 

You can mount the private key `id_rsa` into the ssh folder of the user in the finnet service / test client, i.e. `~/.ssh/` 

e.g.

setting up a test client:

```
docker run -ti --rm -v $(pwd)/id_rsa:/root/.ssh/id_rsa --network finnet-neo4j_neo4j-network alpine sh
```

Replace the network with the actual network created if needed. Install ssh client:

`apk add -U openssh`

Test the commands:

`ssh root@neo4j manager.sh purge`

will purge the existing database

`ssh root@neo4j manager.sh backup`

will backup the existing database

`ssh root@neo4j manager.sh restore`

will restore the last backup

`ssh root@neo4j`

should fail as the server is set up to only accept the extension commands

## Endpoint hooks

**Note:** The interface has changed from a webhook to providing SSH access to call the scripts

The default port for SSH access is `9000`. Access to the Neo4j is controlled via using the appropriate SSH keys, and providing access via the user running the neo4j service (which is `root` in the docker image and `neo4j` in a normal server setup). This setting up of SSH keys have to be done manually. A script `insert_ssh_keys.sh` has been provided to make it easier. Invoke `insert_ssh_keys -h` for more information.

### Backup

Backup the existing graph database. This is done by SSH-ing into the Neo4j server and calling the script `backup.sh name` where `name` is an optional parameter to name the backup file. If `name` is not provided, the endpoint will use database system's current date.

```bash
ssh $neo4jserver -p $hookport "manager.sh backup backup-filename"
```

### Purge

Remove the existing graph database. This is done by SSH-ing into the Neo4j server and calling the script `purge.sh`.

```bash
ssh $neo4jserver -p $hookport "manager.sh purge"
```

### Restore

Restore the graph database from a backup file. This is done by SSH-ing into the Neo4j server and calling the script `restore.sh name` where `name` is an optional parameter to specify the backup file to restore from. If `name` is not provided, the endpoint will use the latest backup file based on the modified date.

```bash
ssh $neo4jserver -p $hookport "manager.sh restore backup-filename"
```

### Cleanup

Remove backup files older than 30 days. This is done by SSH-ing into the Neo4j server and calling the script `cleanup.sh`.

```bash
ssh $neo4jserver -p $hookport "manager.sh cleanup"
```


### Import

Import the graph database from a zip file consisting of csv files corresponding to the nodes and edges. This is done by first copying the zip file into the Neo4j server via SCP and then calling the script `builddb.sh name` where `name` is the full path to the zip file to restore from.

```bash
scp -P $hookport $importzipfile $neo4jserver:$filepath
ssh $neo4jserver -p $hookport "manager.sh builddb $filepath/$importzipfile"


## Packaging as a RPM

Running the script `build-packaging.sh` will build a RPM which can be installed in the host machine (with Neo4j installed) as a service.

To install the RPM on the host machine:
```
sudo rpm -i neo4j-extension*.rpm
```
Neo4j has to be installed first before installing the custom addons.
