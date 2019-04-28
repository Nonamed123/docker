FROM        quay.io/prometheus/busybox:latest

COPY stackdriver_exporter /bin/stackdriver_exporter

ENTRYPOINT ["/bin/stackdriver_exporter"]
EXPOSE 9255
