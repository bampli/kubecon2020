#!/bin/bash -e

export USER=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.username}" | base64 --decode)
export PASS=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.password}" | base64 --decode)

echo "user=$USER / password=$PASS"

#curl -L -X POST 'http://localhost:8081/v1/auth' -H 'Content-Type: application/json' --data-raw "{'username': $USER,'password': $PASS}"
