# docker
## dangling - удаление "висячих" отсатков образов а также томов
Remove dangling volumes - Docker 1.9 and later
Since the point of volumes is to exist independent from containers, when a container is removed, a volume is not automatically removed at the same time. When a volume exists and is no longer connected to any containers, it's called a dangling volume. To locate them to confirm you want to remove them, you can use the docker volume ls command with a filter to limit the results to dangling volumes. When you're satisfied with the list, you can remove them all with docker volume prune:

List:

docker volume ls -f dangling=true
Remove:

docker volume prune
Неиспользуемое изображение означает, что оно не было назначено или использовано в контейнере. Например, при запуске docker ps -a- в нем будут перечислены все ваши вышедшие и запущенные в данный момент контейнеры. Любые изображения, показанные как используемые внутри любого из контейнеров, являются «использованным изображением».

С другой стороны, висящее изображение просто означает, что вы создали новую сборку изображения, но ему не дали новое имя. Таким образом, старые образы, которые у вас есть, становятся «висячим образом». Эти старые изображения являются непомеченными и отображают " <none>" на своем имени при запуске docker images.

При запуске docker system prune -aон удалит неиспользуемые и свисающие изображения. Поэтому любые изображения, используемые в контейнере, вне зависимости от того, были ли они завершены или запущены в данный момент, НЕ будут затронуты.
# Homework 28 (kubernetes-1)
Build Status

Creted new Deploement manifests in kubernetes/reddit folder:
comment-deployment.yml
mongo-deployment.yml
post-deployment.yml
ui-deployment.yml
Kubernetes The Hard Way
This lab assumes you have access to the Google Cloud Platform. This lab we use MacOS.

Prerequisites
Install the Google Cloud SDK
Follow the Google Cloud SDK documentation to install and configure the gcloud command line utility.

Verify the Google Cloud SDK version is 218.0.0 or higher: gcloud version

Default Compute Region and Zone The easiest way to set default compute region: gcloud init.
Otherwise set a default compute region: gcloud config set compute/region us-west1.

Set a default compute zone: gcloud config set compute/zone us-west1-c.

Installing the Client Tools
Install CFSSL
The cfssl and cfssljson command line utilities will be used to provision a PKI Infrastructure and generate TLS certificates.

Installing cfssl and cfssljson using packet manager brew: brew install cfssl.

Verification Installing
cfssl version
Install kubectl
The kubectl command line utility is used to interact with the Kubernetes API Server.

Download and install kubectl from the official release binaries:
curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/darwin/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
Verify kubectl version 1.12.0 or higher is installed:
kubectl version --client
Provisioning Compute Resources
Virtual Private Cloud Network Create the kubernetes-the-hard-way custom VPC network:
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom
A subnet must be provisioned with an IP address range large enough to assign a private IP address to each node in the Kubernetes cluster.

Create the kubernetes subnet in the kubernetes-the-hard-way VPC network:

gcloud compute networks subnets create kubernetes \
  --network kubernetes-the-hard-way \
  --range 10.240.0.0/24
The 10.240.0.0/24 IP address range can host up to 254 compute instances.

Firewall
Create a firewall rule that allows internal communication across all protocols:

gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  --allow tcp,udp,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 10.240.0.0/24,10.200.0.0/16
Create a firewall rule that allows external SSH, ICMP, and HTTPS:

gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 0.0.0.0/0
List the firewall rules in the kubernetes-the-hard-way VPC network:

gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"
output

NAME                                    NETWORK                  DIRECTION  PRIORITY  ALLOW                 DENY  DISABLED
kubernetes-the-hard-way-allow-external  kubernetes-the-hard-way  INGRESS    1000      tcp:22,tcp:6443,icmp        False
kubernetes-the-hard-way-allow-internal  kubernetes-the-hard-way  INGRESS    1000      tcp,udp,icmp                False
Kubernetes Public IP Address
Allocate a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:

gcloud compute addresses create kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region)
Verify the kubernetes-the-hard-way static IP address was created in your default compute region:

gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"
Compute Instances The compute instances in this lab will be provisioned using Ubuntu Server 18.04, which has good support for the containerd container runtime. Each compute instance will be provisioned with a fixed private IP address to simplify the Kubernetes bootstrapping process.

Kubernetes Controllers Create three compute instances which will host the Kubernetes control plane:

for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,controller
done
Kubernetes Workers Each worker instance requires a pod subnet allocation from the Kubernetes cluster CIDR range. The pod subnet allocation will be used to configure container networking in a later exercise. The pod-cidr instance metadata will be used to expose pod subnet allocations to compute instances at runtime.
The Kubernetes cluster CIDR range is defined by the Controller Manager's --cluster-cidr flag. In this tutorial the cluster CIDR range will be set to 10.200.0.0/16, which supports 254 subnets.

Create three compute instances which will host the Kubernetes worker nodes:

for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
done
Verification List the compute instances in your default compute zone:
gcloud compute instances list
output

NAME          ZONE            MACHINE_TYPE               PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
controller-0  europe-west4-a  n1-standard-1                           10.240.0.10  X.X.X.X         RUNNING
controller-1  europe-west4-a  n1-standard-1                           10.240.0.11  X.X.X.X         RUNNING
controller-2  europe-west4-a  n1-standard-1                           10.240.0.12  X.X.X.X         RUNNING
worker-0      europe-west4-a  n1-standard-1                           10.240.0.20  X.X.X.X         RUNNING
worker-1      europe-west4-a  n1-standard-1                           10.240.0.21  X.X.X.X         RUNNING
worker-2      europe-west4-a  n1-standard-1                           10.240.0.22  X.X.X.X         RUNNING
Configuring SSH Access SSH will be used to configure the controller and worker instances. When connecting to compute instances for the first time SSH keys will be generated for you and stored in the project or instance metadata as describe in the connecting to instances documentation.
Test SSH access to the controller-0 compute instances:

gcloud compute ssh controller-0
If this is your first time connecting to a compute instance SSH keys will be generated for you.

Provisioning a CA and Generating TLS Certificates
Certificate Authority
Generate the CA configuration file, certificate, and private key:

{
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}
Client and Server Certificates
Generate the admin client certificate and private key:

{
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
}
The Kubelet Client Certificates
Kubernetes uses a special-purpose authorization mode called Node Authorizer, that specifically authorizes API requests made by Kubelets.

Generate a certificate and private key for each Kubernetes worker node:

for instance in worker-0 worker-1 worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
The Controller Manager Client Certificate
Generate the kube-controller-manager client certificate and private key:

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
The Kube Proxy Client Certificate
Generate the kube-proxy client certificate and private key:

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
The Scheduler Client Certificate
Generate the kube-scheduler client certificate and private key:

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
The Kubernetes API Server Certificate
The kubernetes-the-hard-way static IP address will be included in the list of subject alternative names for the Kubernetes API Server certificate. This will ensure the certificate can be validated by remote clients.

Generate the Kubernetes API Server certificate and private key:

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
The Service Account Key Pair
The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as describe in the managing service accounts documentation.

Generate the service-account certificate and private key:

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
Distribute the Client and Server Certificates
Copy the appropriate certificates and private keys to each worker instance:

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done
Copy the appropriate certificates and private keys to each controller instance:

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done
Generating Kubernetes Configuration Files for Authentication
In this lab you will generate Kubernetes configuration files, also known as kubeconfigs, which enable Kubernetes clients to locate and authenticate to the Kubernetes API Servers.

In this section you will generate kubeconfig files for the controller manager, kubelet, kube-proxy, and scheduler clients and the admin user.

Kubernetes Public IP Address Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.
Retrieve the kubernetes-the-hard-way static IP address:

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
The kubelet Kubernetes Configuration File
When generating kubeconfig files for Kubelets the client certificate matching the Kubelet's node name must be used. This will ensure Kubelets are properly authorized by the Kubernetes Node Authorizer.

Generate a kubeconfig file for each worker node:

for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
The kube-proxy Kubernetes Configuration File
Generate a kubeconfig file for the kube-proxy service:

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
The kube-controller-manager Kubernetes Configuration File
Generate a kubeconfig file for the kube-controller-manager service:

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
The kube-scheduler Kubernetes Configuration File
Generate a kubeconfig file for the kube-scheduler service:

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
The admin Kubernetes Configuration File
Generate a kubeconfig file for the admin user:

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
Distribute the Kubernetes Configuration Files Copy the appropriate kubelet and kube-proxy kubeconfig files to each worker instance:
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
Copy the appropriate kube-controller-manager and kube-scheduler kubeconfig files to each controller instance:

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
Generating the Data Encryption Config and Key
Kubernetes stores a variety of data including cluster state, application configurations, and secrets. Kubernetes supports the ability to encrypt cluster data at rest.

In this lab you will generate an encryption key and an encryption config suitable for encrypting Kubernetes Secrets.

The Encryption Key
Generate an encryption key:

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
The Encryption Config File Create the encryption-config.yaml encryption config file:
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
Copy the encryption-config.yaml encryption config file to each controller instance:

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done
Bootstrapping the etcd Cluster
Kubernetes components are stateless and store cluster state in etcd. In this lab you will bootstrap a three node etcd cluster and configure it for high availability and secure remote access.

Prerequisites
The commands in this lab must be run on each controller instance: controller-0, controller-1, and controller-2. Login to each controller instance using the gcloud command. Example: gcloud compute ssh controller-0

Bootstrapping an etcd Cluster Member
Download and Install the etcd Binaries from the coreos/etcd GitHub project:

wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz"
Extract and install the etcd server and the etcdctl command line utility:

  tar -xvf etcd-v3.3.9-linux-amd64.tar.gz
  sudo mv etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin/
Configure the etcd Server
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP address for the current compute instance:

INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

ETCD_NAME=$(hostname -s)
Create the etcd.service systemd unit file:

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
Start the etcd Server
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
Verification
List the etcd cluster members:

sudo ETCDCTL_API=3 etcdctl member list \
   --endpoints=https://127.0.0.1:2379 \
   --cacert=/etc/etcd/ca.pem \
   --cert=/etc/etcd/kubernetes.pem \
   --key=/etc/etcd/kubernetes-key.pem
output:

3a57933972cb5131, started, controller-2, https://10.240.0.12:2380, https://10.240.0.12:2379
f98dc20bce6225a0, started, controller-0, https://10.240.0.10:2380, https://10.240.0.10:2379
ffed16798470cab5, started, controller-1, https://10.240.0.11:2380, https://10.240.0.11:2379










* Пройти Kubernetes The Hard Way;
* Проверить, что kubectl apply -f проходит по созданным до этого
deployment-ам (ui, post, mongo, comment) и поды запускаются;
    все созданные в ходе туториала файлы (кроме бинарных) помещены в папку kubernetes/the_hard_way репозитория
    проверено, что kubectl apply -f проходит по созданным до этого deployment-ам (ui, post, mongo, comment) и поды запускаются

## 28.1 Как запустить проект

    в каталоге /kubernetes/reddit:

kubectl apply -f post-deployment.yml
kubectl apply -f mongo-deployment.yml
kubectl apply -f ui-deployment.yml
kubectl apply -f comment-deployment.yml

## 28.2 Как проверить

    в каталоге /kubernetes/reddit:

kubectl get pods

    пример вывода:

NAME                                 READY   STATUS              RESTARTS   AGE
busybox-bd8fb7cbd-qw5mj              1/1     Running             0          13m
comment-deployment-b58ddd4cc-mfktv   1/1     Running             0          11s
mongo-deployment-67f58fb89-cglqv     1/1     Running             0          17s
nginx-dbddb74b8-nfjqt                1/1     Running             0          10m
post-deployment-977786747-7w2rp      1/1     Running             0          2m26s
ui-deployment-7c95b5b68c-pdtdl       1/1     Running             0          6s
untrusted                            1/1     Running             0          5m19s

* Удалить кластер после прохождения THW;
Cleaning Up
In this lab you will delete the compute resources created during this tutorial.

Compute Instances
Delete the controller and worker compute instances:

gcloud -q compute instances delete \
  controller-0 controller-1 controller-2 \
  worker-0 worker-1 worker-2
Networking
Delete the external load balancer network resources:

{
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
    --region $(gcloud config get-value compute/region)

  gcloud -q compute target-pools delete kubernetes-target-pool

  gcloud -q compute http-health-checks delete kubernetes

  gcloud -q compute addresses delete kubernetes-the-hard-way
}
Delete the kubernetes-the-hard-way firewall rules:

gcloud -q compute firewall-rules delete \
  kubernetes-the-hard-way-allow-nginx-service \
  kubernetes-the-hard-way-allow-internal \
  kubernetes-the-hard-way-allow-external \
  kubernetes-the-hard-way-allow-health-check
Delete the kubernetes-the-hard-way network VPC:

{
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24 \
    kubernetes-route-10-200-2-0-24

  gcloud -q compute networks subnets delete kubernetes

  gcloud -q compute networks delete kubernetes-the-hard-way
}
* Все созданные в ходе прохождения THW файлы (кроме
бинарных) поместить в папку kubernetes/the_hard_way
репозитория (сертификаты и ключи тоже можно коммитить, но
только после удаления кластера).

# Homework 27 Docker Swarm
## 27.1 Что было сделано
В результате выполнения docker swarm init:
• Текущая нода переключается в Swarm-режим
• Текущая нода назначается в качестве Лидера менеджеров кластера
• Ноде присваивается хостнейм машины
• Менеджер конфигурируется для прослушивания на порту 2377
• Текущая нода получает статус Active, что означает возможность
получать задачки от планировщика
•
Запускается внутреннее распределенное хранилище данных Docker для
работы оркестратора
• Генерируется самоподписный корневый (CA) сертификат для Swarm
• Генерируются токены для присоединения Worker и Manager нод к
кластеру
•
## Создается Overlay-сеть Ingress для публикации сервисов наружу
Строим Swarm Cluster
На хостах worker-1 и worker-2 выполнить:
$ docker swarm join --token <ваш токен> <advertise адрес manager’a>:237
Подключаемся к master-1 ноде (ssh или eval $(docker-machine ...))
Дальше работать будем только с ней. Команды в рамках Swarm-
кластера можно запускать только на Manager-нодах.
Проверим состояние кластера.
$ docker node ls
## Размещаем сервисы
Ограничения размещения определяются с помощью логических
действий со значениями label-ов (медатанных) нод
и docker-engine’ов
Запущена инфраструктура с мониторингом созданы несколько окружений.
env $(cat .env | grep ^[A-Z] | xargs) docker stack deploy --with-registry-auth --compose-file docker-compose.yml name stacr
This comand for othe connect stack name.
# Homework 24 Logging-1
## 24.1 Что было сделано

    код в директории /src репозитория обновлен
    в /src/post-py/Dockerfile добавлена установка пакетов gcc и musl-dev
    пересобраны образы из корня репозитория:

for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done

    создан Docker хост в GCE и настроено локальное окружение на работу с ним:

docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    logging
eval $(docker-machine env logging)
docker-machine ip logging

    создан отдельный compose-файл для системылогирования docker/docker-compose-logging.yml
    создан logging/fluentd/Dockerfile со следущим содержимым:

FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc

    в директории logging/fluentd создан файл конфигурации fluent.conf
    собран docker image для fluentd

docker build -t $USER_NAME/fluentd

    в .env файле и заменены теги приложения на logging
    запущены сервисы приложения

docker-compose up -d

    просмотра логов post сервиса:

docker-compose logs -f post 

    определен драйвер для логирования для сервиса post внутри compose-файла
    поднята инфраструктура централизованной системы логирования и перезапущены сервисы приложения:

docker-compose -f docker-compose-logging.yml up -d
docker-compose down
docker-compose up -d 

    через веб-интерфейс Kibana (порт 5601) создан индекс-маппинг для fluentd и просмотрены собранные логи
    добавлен фильтр для парсинга json логов, приходящих от post сервиса, в конфиг logging/fluentd/fluent.conf:

<filter service.post>
  @type parser
  format json
  key_name log
</filter> 

    пересобран образ и перезапущен сервис fluentd

docker build -t $USER_NAME/fluentd
docker-compose -f docker-compose-logging.yml up -d fluentd

    по аналогии с post сервисом определен для ui сервиса драйвер для логирования fluentd в compose-файле docker/docker-compose.yml
    перезапущен ui сервис из каталога docker

docker-compose stop ui
docker-compose rm ui
docker-compose up -d 

    использованы регулярные выражения для парсинга неструктурированных логов в /docker/fluentd/fluent.conf
    пересобран образ и перезапущен сервис fluentd

docker build -t $USER_NAME/fluentd
docker-compose -f docker-compose-logging.yml up -d fluentd

    добавлены grok шаблоны для парсинга неструктурированных логов в /docker/fluentd/fluent.conf
    пересобран образ и перезапущен сервис fluentd, работа проверена

## 24.2 Как запустить проект

    в каталоге /docker:

docker-compose up -d
docker-compose -f docker-compose-logging.yml up -d

## 24.3 Как проверить

    перейти в браузере по ссылке http://docker-host_ip:5601 (kibana)

# Homework 23 Monitoring-2
## 23.1 Что было сделано

    созданы правила фаервола для Prometheus, Puma, Cadvisor, Grafana:

gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
gcloud compute firewall-rules create grafana-default --allow tcp:3000

    создан Docker хост в GCE и настроено локальное окружение на работу с ним:

export GOOGLE_PROJECT=_ваш-проект_
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host
eval $(docker-machine env docker-host)
docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus

    мониторинг выделен в отдельный файл docker-compose-monitoring.yml
    добавлен новый сервис cadvisor в компоуз файл мониторинга docker-composemonitoring.yml
    запущен сервис grafana

docker-compose -f docker-compose-monitoring.yml up -d grafana

    пересобран образ Prometheus с обновленной конфигурацией, запущены сервисы:

$ export USER_NAME=username
$ docker build -t $USER_NAME/prometheus .
$ docker-compose up -d
$ docker-compose -f docker-compose-monitoring.yml up -d

    проверена работа cadvisor
    добавлен новый сервис grafana в компоуз файл мониторинга docker-compose-monitoring.yml
    в grafana через webUI добавлен источник данных prometheus
    работа grafana протестирована, json файлы дашбордов в директории monitoring/grafana/dashboards
    подняты сервисы, определенные в docker/dockercompose.yml, протестирована работа Prometheus
    определен еще один сервис alertmanager (monitoring/Dockerfile)
    в директории monitoring/alertmanager создан файл config.yml, в котором определена отправка нотификаций в тестовый слак канал
    собран образ alertmanager

docker build -t $USER_NAME/alertmanager .

    добавлен новый сервис alertmanager в компоуз файл мониторинга docker-composemonitoring.yml
    создан файл alerts.yml в директории prometheus

groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'

    операцию копирования данного файла добавлена в Dockerfile (ADD alerts.yml /etc/prometheus/)
    информацию о правилах добавлена в конфиг Prometheus

rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"

    пересобран образ Prometheus, пересоздана Docker инфраструктура мониторинга:

docker build -t $USER_NAME/prometheus .
docker-compose -f docker-compose-monitoring.yml down
docker-compose -f docker-compose-monitoring.yml up -d

    работа alertmanager протестирована
    образы запушены на dockerhub - https://hub.docker.com/u/statusxt/

## 23.2 Как запустить проект

    в каталоге /docker:

docker-compose up -d
docker-compose -f docker-compose-monitoring.yml up -d

## 23.3 Как проверить

    перейти в браузере по ссылке http://docker-host_ip:3000 (grafana)
    перейти в браузере по ссылке http://docker-host_ip:9090 (prometheus)
    перейти в браузере по ссылке http://docker-host_ip:8080 (cadvisor)

# Homework 21 Monitoring-1
## 21.1 Что было сделано
создано правило фаервола для Prometheus и Puma:
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
создан Docker хост в GCE и настроено локальное окружение на работу с ним:
$ export GOOGLE_PROJECT=_ваш-проект_
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host
eval $(docker-machine env docker-host)
$ docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus
переупорядочена структура директорий (созданы директории docker и monitoring, в docker перенесены директория docker-monolith и файлы docker-compose.* и все .env)
создан monitoring/prometheus/Dockerfile который будет копировать файл конфигурации с нашей машины внутрь контейнера:
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
в директории monitoring/prometheus создан конфигурационный файл prometheus.yml
в директории prometheus собран Docker образ
$ export USER_NAME=username
$ docker build -t $USER_NAME/prometheus .
выполнена сборка образов при помощи скриптов docker_build.sh в директории каждого сервиса:
/src/ui      $ bash docker_build.sh
/src/post-py $ bash docker_build.sh
/src/comment $ bash docker_build.sh
определен новый сервис Prometheus в docker/docker-compose.yml, удалены build директивы из docker_compose.yml и использованы директивы image
добавлена секция networks в определение сервиса Prometheus в docker/dockercompose.yml
подняты сервисы, определенные в docker/dockercompose.yml, протестирована работа Prometheus
определен еще один сервис node-exporter в docker/docker-compose.yml файле для сбора информации о работе Docker хоста (виртуалки, где у нас запущены контейнеры) и предоставлению этой информации в Prometheus
информация о сервисе node-exporter добавлена в конфиг Prometheus, создан новый образ
scrape_configs:
...
 - job_name: 'node'
 static_configs:
 - targets:
 - 'node-exporter:9100' 
#
monitoring/prometheus $ docker build -t $USER_NAME/prometheus .
сервисы перезапущены
$ docker-compose down
$ docker-compose up -d 
работа экспортера протестирована на примере информации об использовании CPU
собранные образы запушены на DockerHub:
$ docker login
$ docker push $USER_NAME/ui
$ docker push $USER_NAME/comment
$ docker push $USER_NAME/post
$ docker push $USER_NAME/prometheus
ссылка на DockerHub - https://hub.docker.com/u/statusxt/
В рамках задания со *:

в Prometheus добавлен мониторинг MongoDB с использованием percona/mongodb_exporter, Dockerfile в каталоге monitoring/mongodb_exporter
добавлен мониторинг сервисов comment, post, ui с помощью blackbox экспортера prom/blackbox-exporter, Dockerfile и конфиг в каталоге monitoring/blackbox_exporter
создан Makefile с возможностями: build, push, pull, remove, start, stop; билд конкретного образа - make -e IMAGE_PATHS=./src/post-py
## 21.2 Как запустить проект
в каталоге /docker/:
docker-compose up -d
в рамках задания со звездочкой - в корне репозитория:
make build
make start
make push
## 21.3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9090

# Homework 20 Gitlab-CI-2
## 20.1 Что было сделано

    создан новый проект в gitlab-ci
    добавлен новый remote в _microservices:

git checkout -b gitlab-ci-2
git remote add gitlab2 http://<your-vm-ip>/homework/example2.git
git push gitlab2 gitlab-ci-2

    для нового проекта активирован сущестующий runner
    пайплайн изменен таким образом, чтобы job deploy стал определением окружения dev, на которое условно будет выкатываться каждое изменение в коде проекта
    определены два новых этапа: stage и production, первый будет содержать job имитирующий выкатку на staging окружение, второй на production окружение
    staging и production запускаются с кнопки (when: manual)
    в описание pipeline добавлена директива, которая не позволит нам выкатить на staging и production код, не помеченный с помощью тэга в git:

...
staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com
...

    в описание pipeline добавлены динамические окружения, теперь на каждую ветку в git отличную от master Gitlab CI будет определять новое окружение

## 20.2 Как запустить проект

на машине с gitlab-ci в каталоге /srv/gitlab/:

docker-compose up -d

## 20.3 Как проверить

перейти в браузере по ссылке http://docker-host_ip

# Homework 19 Gitlab-CI-1
## 19.1 Что было сделано
создана ВМ в GCP, установлен docker-ce, docker-compose
в каталоге /srv/gitlab/ создан docker-compose.yml с описанием gitlab-ci:
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://35.187.88.136'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
    
запущен gitlab-ci:
docker-compose up -d 
созданы группа и проект в gitlab-ci

добавлен remote в _microservices:
git checkout -b gitlab-ci-1
git remote add gitlab http://<your-vm-ip>/homework/example.git
git push gitlab gitlab-ci-1
создан файл .gitlab-ci.yml с описанием пайплайна
создан и зарегистрирован runner:
docker run -d --name gitlab-runner --restart always \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest 
docker exec -it gitlab-runner gitlab-runner register
добавлен исходный код reddit в репозиторий:
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab gitlab-ci-1
в описание pipeline добавлен вызов теста в файле simpletest.rb
добавлена библиотека для тестирования в reddit/Gemfile приложения
теперь на каждое изменение в коде приложения будет запущен тест
Интеграция со slack чатом:

Project Settings > Integrations > Slack notifications. Нужно установить active, выбрать события и заполнить поля с URL Slack webhook
ссылка на тестовый канал https://nonamed-hq.slack.com/archives/CF2BB9CHG/p1554983084000200

# Homework 17 Docker-4#

## 17.1 Что было сделано

    протестирована работа контейнера с использованием none и host драйвера

docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker ps
docker run --network host --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker-machine ssh docker-host ifconfig
docker run --network host -d nginx
docker run --network host -d nginx

    nginx запустить несколько раз не получится, потому что порт будет занят первым запущенным экземпляром
    при запуске контейнера с none драйвером создается новый namespace, при запуске с host драйвером используется namespace хоста
    создана bridge-сеть в docker, запущен проект с использоваением этой сети:

docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment  statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0

    созданы 2 bridge-сети в docker, запущен проект с использоваением этих сетей:

docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker run -d --network=front_net -p 9292:9292 --name ui  statusxt/ui:1.0
docker run -d --network=back_net --name comment  statusxt/comment:1.0
docker run -d --network=back_net --name post  statusxt/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
docker network connect front_net post
docker network connect front_net comment

    установлен docker-compose

pip install docker-compose 

    создан файл dockercompose.yml с описанием проекта
    в dockercompose.yml добавлены 2 сети, сетевые алиасы, параметризованы порт публикации, версии сервисов
    переменные задаются в файле .env
    базовое имя проета задется переменной COMPOSE_PROJECT_NAME
    работа docker-compose проверена:

docker-compose up -d
docker ps

## 17.2 Как запустить проект

в каталоге src:

docker kill $(docker ps -q)

## 17.3 Как проверить

перейти в браузере по ссылке http://docker-host_ip:9292
# Homework 15-16 Docker-4
## 15.1 Что было сделано
протестирована работа контейнера с использованием none и host драйвера
docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker ps
docker run --network host --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker-machine ssh docker-host ifconfig
docker run --network host -d nginx
docker run --network host -d nginx
nginx запустить несколько раз не получится, потому что порт будет занят первым запущенным экземпляром
при запуске контейнера с none драйвером создается новый namespace, при запуске с host драйвером используется namespace хоста
создана bridge-сеть в docker, запущен проект с использоваением этой сети:
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment  statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
созданы 2 bridge-сети в docker, запущен проект с использоваением этих сетей:
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker run -d --network=front_net -p 9292:9292 --name ui  statusxt/ui:1.0
docker run -d --network=back_net --name comment  statusxt/comment:1.0
docker run -d --network=back_net --name post  statusxt/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
docker network connect front_net post
docker network connect front_net comment
установлен docker-compose
pip install docker-compose 
создан файл dockercompose.yml с описанием проекта
в dockercompose.yml добавлены 2 сети, сетевые алиасы, параметризованы порт публикации, версии сервисов
переменные задаются в файле .env
базовое имя проекта задется переменной COMPOSE_PROJECT_NAME
работа docker-compose проверена:
docker-compose up -d
docker ps
## 15-16.2 Как запустить проект
в каталоге src:

docker kill $(docker ps -q)
docker-compose up -d
## 15-16 .3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9292

# Homework 14 Docker-3
## 14.1 Что было сделано
скачан архив с микросервисами и распакован в src
созданы Dockerfile для сборки post-py, comment, ui
docker build -t statusxt/post:1.0 ./post-py
docker build -t statusxt/comment:1.0 ./comment
docker build -t statusxt/ui:1.0 ./ui
создана сеть для приложения
docker network create reddit
запущены контейнеры:
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:1.0
создан docker volume для mongodb
 docker volume create reddit_db 
контейнеры перезапущены с новыми парметрами, теперь данные в базе не зависят о перезапуска контейнеров
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
В рамках задания со *:

запущены контейнеры с другими сетевыми алиасами, при запуске контейнеров (docker run) заданы переменные окружения соответствующие новым сетевым алиасам:
docker run -d --network=reddit --network-alias=post_db_1 \
              --network-alias=comment_db_1 mongo:latest
docker run -d --network=reddit --network-alias=post_1 \
              -e POST_DATABASE_HOST=post_db_1 andywow/post:1.0
docker run -d --network=reddit --network-alias=comment_1 \
              -e COMMENT_DATABASE_HOST=comment_db_1 andywow/comment:1.0
docker run -d --network=reddit -p 9292:9292 --network-alias=ui \
              -e COMMENT_SERVICE_HOST=comment_1 \
              -e POST_SERVICE_HOST=post_1 andywow/ui:1.0
собран образ на основе alpine linux
произведены оптимизации ui образа - удаление кэша, приложений для сборки
statusxt/ui    5.0    521a666364d1    23 hours ago    58.5MB
statusxt/ui    4.0    223d64bf1a3a    23 hours ago    209MB
statusxt/ui    3.0    c4c2f1396a5b    24 hours ago    58.4MB
statusxt/ui    2.0    8e8787069c58    25 hours ago    460MB
statusxt/ui    1.0    8c6d705411e2    25 hours ago    778MB
## 14.2 Как запустить проект
### 14.2.1 Base
в каталоге src:

docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
### 14.2.2 *
в каталоге src:

docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:5.0
## 14.3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9292
