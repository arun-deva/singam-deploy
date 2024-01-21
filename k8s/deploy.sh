#!/bin/bash
script_dir=$(dirname $0)
mkdir -p $script_dir/nginx_edge
wget -O $script_dir/nginx_edge/default.conf.template https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/nginx_edge/default.conf.template
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/landing-page.yaml
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/minesweeper.yaml
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/aadupuli.yaml
kubectl apply -f https://raw.githubusercontent.com/arun-deva/singam-deploy/master/k8s/guess-that-song.yaml
#get ing controller node port
while [ -z "$node_port" ]; do
    echo "Getting node port..."
    node_port=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.appProtocol=="http")].nodePort}')
    sleep 2;
done
echo "Got node port: ${node_port}"

#create nginx conf template for substitution
docker run -d -p 80:80 --name nginx_edge -e NODE_PORT=${node_port} -v ${script_dir}/nginx_edge:/etc/nginx/templates/ --rm nginx:alpine