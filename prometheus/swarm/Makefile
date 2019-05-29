username = nonamed123
.DEFAULT_GOAL := all

build: build-alertmanager build-stackdriverexp build-cloudprober build-blackbox build-mongodexp build-fluentd build-prometheus build-comment build-ui build-post 
#build: build-comment build-ui build-post
build-cloudprober:
	cd /etc/docker/micro/microservices/prometheus/swarm/cloudprober && docker build -t $(username)/cloudprober-exporter .
build-prometheus:
	cd /etc/docker/micro/microservices/prometheus/swarm/ && docker build -t $(username)/prometheus .
build-comment:
	cd /etc/docker/micro/microservices/prometheus/swarm/comment/ && bash docker_build.sh
build-ui:
	cd /etc/docker/micro/microservices/prometheus/swarm/ui/ && bash docker_build.sh
build-post:
	cd /etc/docker/micro/microservices/prometheus/swarm/post-py/ && bash docker_build.sh

build-blackbox:
	cd /etc/docker/micro/microservices/prometheus/swarm/blackbox_exporter/ && docker build -t $(username)/blackbox_exporter .
build-mongodexp:
	cd /etc/docker/micro/microservices/prometheus/swarm/mongodb_exporter/ && docker build -t $(username)/mongodb_exporter .
build-alertmanager:
	cd /etc/docker/micro/microservices/prometheus/swarm/alertmanager/ && docker build -t $(username)/alertmanager .
build-stackdriverexp:
	cd /etc/docker/micro/microservices/prometheus/swarm/stackdriver_exporter/ && docker build -t $(username)/stackdriver_exporter . 
#	cd /etc/docker/micro/microservices/prometheus/stackdriver_exporter/ &&  docker run -p 9255:9255 frodenas/stackdriver-exporter --google.project-id hardy-symbol-235210 --monitoring.metrics-type-prefixes "compute.googleapis.com/instance/cpu,compute.googleapis.com/instance/disk"
#	cd /etc/docker/micro/microservices/prometheus/stackdriver_exporter/ &&	docker builr -t 9255:9255 $(username)/stackdriver-exporter --google.project-id hardy-symbol-235210 --monitoring.metrics-type-prefixes "compute.googleapis.com/instance/cpu,compute.googleapis.com/instance/disk"
build-fluentd:
	cd /etc/docker/micro/microservices/prometheus/swarm/logining1/ && docker build -t $(username)/fluentd . 

start:
	cd /etc/docker/micro/microservices/prometheus/swarm && docker stack deploy --compose-file=<(docker-compose -f docker-compose.yml config 2>/dev/null) DEV

stop:
	cd /etc/docker/micro/microservices/prometheus/swarm && docker-compose down

default: build



