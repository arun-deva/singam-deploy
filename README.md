## Build and push Docker image for singam-nginx (in dev env)
Assumes that latest ui tgz files are in the ui-dist directory

```./build.sh```

## Kubernetes Deploy (local)
```
minikube start
minikube addons enable ingress
kubectl apply -f k8s/landing-page.yaml
kubectl apply -f k8s/minesweeper.yaml
kubectl apply -f k8s/aadupuli.yaml
kubectl apply -f k8s/guess-that-song.yaml
```

## Kubernetes Deploy (destination)
```shell
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/landing-page.yaml
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/minesweeper.yaml
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/aadupuli.yaml
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/guess-that-song.yaml
```
## Kubernetes initial setup and configuration
### Install kubeadm etc
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
```
sudo apt-get update
sudo apt install containerd
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```
### Configure containerd
https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
```shell
sudo mkdir /etc/containerd
sudo containerd config default |sudo tee /etc/containerd/config.toml
```

In the above file, make following changes:
1. To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set
```shell
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```
2. Use "registry.k8s.io/pause:3.9" as the CRI sandbox image. (required by kubeadm 1.29)

### Configure containerd to run as a systemd service 
https://github.com/containerd/containerd/blob/main/docs/getting-started.md
```
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
vi containerd.service
# Change the path of the executable in the containerd.service file to /usr/bin/containerd instead of /usr/local/bin/containerd
sudo mv containerd.service /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
```

### install cni plugins
```shell
wget https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz
```


### Forwarding IPv4 and letting iptables see bridged traffic
https://kubernetes.io/docs/setup/production-environment/container-runtimes/

Execute the below mentioned instructions:
```shell
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
#Verify that the br_netfilter, overlay modules are loaded by running the following commands:

lsmod | grep br_netfilter
lsmod | grep overlay
#Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```



### Create cluster
Calico CNI requires --pod-network-cidr=192.168.0.0/16
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
#To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

```
### Install CNI (Calico)
https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart#operator-based-installation
```shell
# Install the Tigera Calico operator and custom resource definitions.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
# Install Calico by creating the necessary custom resource
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
# Confirm that all of the pods are running with the following command.
watch kubectl get pods -n calico-system

```
### Remove no schedule taint from control plane node
Since we are running this on a single node, we want to allow scheduling pods on the control-plane node
```shell
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# minus sign on the end of above cmd removes the taint
```
### Install ingress controller
https://kubernetes.github.io/ingress-nginx/deploy/baremetal/
https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/baremetal/deploy.yaml
```

## Deploy (on destination instance)

Pull down the docker compose file from github
```
curl https://raw.githubusercontent.com/arun-deva/singam-deploy/master/docker-compose.yml > /home/ec2-user/singam-deploy/docker-compose.yml
```

```
docker-compose down
docker-compose pull
docker-compose up -d
```

## Note Lightsail on DS account

