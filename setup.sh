# adds modified key to neo4j_keys folder
./add_ssh_key.sh -n 1 -r ~/hmaster_keys/id_rsa.pub
./add_ssh_key.sh -r ~/hmaster-dd_keys/id_rsa.pub

docker run -itd \
-p 7474:7474 -p 7687:7687 --network=my-bridge-network --name=neo4j finnet-neo4j

# volume mount does not work because of some windows permissions issue?
#-v $key_folder:/root/.ssh \
docker cp ./neo4j_keys/authorized_keys neo4j:/root/.ssh/authorized_keys

docker network connect my-bridge-network-dd neo4j
