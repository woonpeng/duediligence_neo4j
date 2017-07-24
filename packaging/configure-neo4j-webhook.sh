#!/usr/bin/env bash

if [ $# -lt 1 ]; 
then
  echo "Usage: configure-neo4j-webhook WEBSECRET"
  echo ""
  echo "WEBSECRET: a secret key that the webhook uses to authenticating requests"
else
  WEBHOOK_SECRET=$1 /opt/neo4j-webhook/gen_hook.sh /etc/opt/neo4j-webhook/hooks.json
  systemctl restart neo4j-webhook
  echo "Successfully configured Neo4j Webhook secrets"
fi
