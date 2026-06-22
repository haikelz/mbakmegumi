#!/usr/bin/env bash

set -euo pipefail

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

required_vars=(DOMAIN EMAIL IMAGE)
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required env var: ${var}. Set it in the shell or .env." >&2
    exit 1
  fi
done

render_apply() {
  envsubst < "$1" | kubectl apply -f -
}

if envsubst < k8s/secret.yaml | grep -q '\${'; then
  echo "Rendered secret.yaml still contains unsubstituted variables. Check your env values." >&2
  exit 1
fi

cd k8s

render_apply secret.yaml
kubectl apply -f services.yaml
kubectl apply -f deployment.yaml
render_apply clusterissuer.yaml
render_apply ingress.yaml
