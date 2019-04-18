#!/bin/bash
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292

docker-machine create --driver google \
--google-project hardy-symbol-235210 \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
vm1
eval $(docker-machine env vm1)
