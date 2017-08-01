#!/usr/bin/env bash

if [ $# -eq 0 ];
then
  echo "Run $0 -h for help"
  exit 0
fi

while getopts "hsck" OPTION; do
  case $OPTION in
    s)
      WEBHOOK_SECRET=$2 {{WEBHOOK_INSTALL_PATH}}/gen_hook.sh {{WEBHOOK_CONFIG_PATH}}/hooks.json
      systemctl restart {{WEBHOOK_SERVICE}}
      echo "Successfully configured Neo4j Webhook secrets"
      ;;

    c)
      if [ -f /etc/systemd/system/neo4j-webhook.service ]; then 
        sed -i "s#Environment=NEO4J_WEBHOOK_CERT=.*#Environment=NEO4J_WEBHOOK_CERT=$2#" /etc/systemd/system/neo4j-webhook.service
        systemctl daemon-reload
        systemctl restart {{WEBHOOK_SERVICE}}
        echo "Successfully configured Neo4j Webhook to use the cert: $2"
        echo "Note that you may have to setup the corresponding key file"
      else
        echo "Neo4j Webhook is not run as a service. You may want to manually export the environment variable NEO4J_WEBHOOK_CERT to point to the cert file"
      fi
      ;;

    k)
      if [ -f /etc/systemd/system/neo4j-webhook.service ]; then 
        sed -i "s#Environment=NEO4J_WEBHOOK_KEY=.*#Environment=NEO4J_WEBHOOK_KEY=$2#" /etc/systemd/system/neo4j-webhook.service
        systemctl daemon-reload
        systemctl restart {{WEBHOOK_SERVICE}}
        echo "Successfully configured Neo4j Webhook to use the key file: $2"
        echo "Note that you may have to setup the corresponding cert file"
      else
        echo "Neo4j Webhook is not run as a service. You may want to manually export the environment variable NEO4J_WEBHOOK_KEY to point to the cert file"
      fi
      ;;

    h)
      echo "Usage: $0 [-hsck]"
      echo ""
      echo "  -h       help"
      echo "  -s key   configure webhook to use the secret 'key'"
      echo "  -c cert  configure webhook to use the given cert file"
      echo "  -k key   configure webhook to use the given key file corresponding to the cert file"
      exit 0
      ;;
  esac
done
