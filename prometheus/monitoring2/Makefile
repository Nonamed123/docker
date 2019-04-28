username = nonamed123
.DEFAULT_GOAL := all

build: build-alertmanager build-stackdriverexp build-cloudprober build-blackbox build-mongodexp build-prometheus build-comment build-ui build-post 

build-cloudprober:
	cd /etc/docker/micro/microservices/prometheus/cloudprober && docker build -t $(username)/cloudprober-exporter .
build-prometheus:
	cd /etc/docker/micro/microservices/prometheus/ && docker build -t $(username)/prometheus .
build-comment:
	cd /etc/docker/micro/microservices/prometheus/comment/ && bash docker_build.sh
build-ui:
	cd /etc/docker/micro/microservices/prometheus/ui/ && bash docker_build.sh
build-post:
	cd /etc/docker/micro/microservices/prometheus/post-py/ && bash docker_build.sh
build-blackbox:
	cd /etc/docker/micro/microservices/prometheus/blackbox_exporter/ && docker build -t $(username)/blackbox_exporter .
build-mongodexp:
	cd /etc/docker/micro/microservices/prometheus/mongodb_exporter/ && docker build -t $(username)/mongodb_exporter .
build-alertmanager:
	cd /etc/docker/micro/microservices/prometheus/alertmanager/ && docker build -t $(username)/alertmanager .
build-stackdriverexp:
	cd /etc/docker/micro/microservices/prometheus/stackdriver_exporter/ && docker build -t $(username)/stackdriver_exporter .

start:
	cd /etc/docker/micro/microservices/prometheus && docker-compose up -d

stop:
	cd /etc/docker/micro/microservices/prometheus && docker-compose down

default: build



