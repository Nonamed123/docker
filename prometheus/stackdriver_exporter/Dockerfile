FROM        quay.io/prometheus/busybox:latest

COPY stackdriver_exporter /bin/stackdriver_exporter
#ENV GOOGLE_APPLICATION_CREDENTIALS /home/buldozer/Downloads/hardy-symbol-235210-58b1ba999933.json
ENV STACKDRIVER_EXPORTER_GOOGLE_PROJECT_ID hardy-symbol-235210
ENV STACKDRIVER_EXPORTER_MONITORING_METRICS_TYPE_PREFIX compute.googleapis.com/instance/cpu,compute.googleapis.com/instance/disk
ENTRYPOINT ["/bin/stackdriver_exporter"]
EXPOSE 9255
