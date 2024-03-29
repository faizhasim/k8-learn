# Kind with ArgoCD

## Getting Started


### Run [./scripts/install.sh](./scripts/install.sh) which will do the following:

    ./scripts/install.sh

1. Create a kind cluster
2. Install nginx-ingress
3. Install ArgoCD
4. Print instruction on how to connect to ArgoCD.

### Delete cluster with kind

    kind delete cluster --name kind