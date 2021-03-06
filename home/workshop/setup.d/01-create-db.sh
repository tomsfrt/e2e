#!/bin/bash

set -x

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
sleep 1000
helm upgrade -i petclinic-db bitnami/mysql --version 6.14.11 -f <(cat petclinic-db-values.yaml | envsubst)
