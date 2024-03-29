#!/bin/sh

set -euo pipefail

print() {
  echo
  echo "$(tput bold)$(tput setaf 3)$1$(tput sgr0)"
  echo
}

print "Creating a kind cluster with argocd"
kind create cluster --config=kind-argocd.yaml || true

print "install ingress-nginx"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

print "wait for ingress-nginx to be ready"
kubectl rollout status -w -n ingress-nginx deployment/ingress-nginx-controller --timeout=600s
kubectl wait --for=condition=initialized pod -l app.kubernetes.io/component=admission-webhook -n ingress-nginx --timeout=120s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=120s
print "ingress-nginx is ready"

print "install argocd"
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || true

print "waiting for argocd to be ready"
kubectl rollout status -w -n argocd deployment/argocd-server --timeout=600s
kubectl rollout status -w -n argocd deployment/argocd-redis --timeout=600s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd
print "argocd is ready"

kubectl apply -f ingress-argocd.yaml && sleep 3

print "print initial argocd password"

echo "$(tput bold)$(tput setaf 3)"
echo "What's next:"
echo
echo "1. Register /etc/host with:"
echo "$(tput sgr0)"
echo "   127.0.0.1       argocd-server.local"
echo "$(tput bold)$(tput setaf 3)"
echo "2. Access argocd at: https://argocd-server.local using:"
echo "$(tput sgr0)"
echo "   username: admin"
echo "   password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
echo ""
