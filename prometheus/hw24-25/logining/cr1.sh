#!/bin/bash
docker-machine create --driver google \
    --google-project hardy-symbol-235210 \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    --google-open-port 80/tcp \
    --google-open-port 3000/tcp \
    --google-open-port 8080/tcp \
    --google-open-port 9090/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9093/tcp \
    --google-open-port 9255/tcp \
    --google-open-port 5061/tcp \
    logging
eval $(docker-machine env logging)
docker-machine ip logging
