#!/bin/bash
set -e
set -u
set -o pipefail
if [[ "$(basename ${PWD})" == "deployments" ]]; then
	cd ..
fi

repository="https://grafana.github.io/helm-charts"
chart="loki"
version="4.8.0"
namespace="${chart}"

kubeapi_hostname=$(cat terraform/output.json | jq -r .kubeone_api.value.endpoint)
cat > "deployments/${chart}.values.yaml" <<EOF
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: filesystem
test:
  enabled: false
monitoring:
  dashboards:
    enabled: false
  rules:
    enabled: false
    alerting: false
  serviceMonitor:
    enabled: false
  selfMonitoring:
    enabled: false
    grafanaAgent:
      installOperator: false
  lokiCanary:
    enabled: false
singleBinary:
  replicas: 1
  persistence:
    size: 20Gi
EOF
deployments/install-chart.sh "${repository}" "${chart}" "${version}" "deployments/${chart}.values.yaml"
