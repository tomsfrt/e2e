#!/bin/bash

set -x

REGISTRY_PASSWORD=$HARBOR_PASSWORD kp secret create harbor-creds --registry harbor.e2e.tsfrt.info --registry-user admin
