#!/bin/bash
apt install -y kubeadm kubelet kubectl
kubectl apply -f k8s/cni/calico.yaml
kubectl apply -f k8s/manifests/deployment.yaml
