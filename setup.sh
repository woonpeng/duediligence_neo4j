docker run -itd \
-v $data_folder:/var/lib/neo4j/data \
-v $logs_folder:/var/lib/neo4j/logs \
-v $import_folder:/var/lib/neo4j/import \
-v $plugins_folder:/var/lib/neo4j/plugins \
-p 7474:7474 -p 7687:7687 --network=my-bridge-network --name=neo4j finnet-neo4j
