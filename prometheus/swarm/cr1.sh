#!/bin/bash
docker-machine create --driver google \
--google-project hardy-symbol-235210  \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
master-1

docker-machine create --driver google \
--google-project hardy-symbol-235210  \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
worker-1


docker-machine create --driver google \
--google-project hardy-symbol-235210  \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
worker-2

docker-machine create --driver google \
--google-project hardy-symbol-235210  \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
worker-3
