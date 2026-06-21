  #!/usr/bin/env bash

  set -euo pipefail
  set -a
  source .env
  set +a

  envsubst < k8s/clusterissuer.yaml | kubectl apply -f -
  envsubst < k8s/deployment.yaml | kubectl apply -f -
  envsubst < k8s/ingress.yaml | kubectl apply -f -
  kubectl apply -f k8s/service.yaml
