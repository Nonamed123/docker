#!/bin/bash
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292

docker-machine create --driver google \
--google-project hardy-symbol-235210 \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
--google-open-port 80/tcp \
--google-open-port 3000/tcp \
--google-open-port 8080/tcp \
--google-open-port 9090/tcp \
--google-open-port 9292/tcp \
--google-open-port 9093/tcp \
--google-open-port 9255/tcp \
vm1


eval $(docker-machine env vm1)

export USER_NAME=nonamed123
export USERNAME=nonamed123

