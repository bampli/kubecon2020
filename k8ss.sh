#!/bin/bash -e

# K8SSANDRA
#
# Original Guide: https://github.com/DataStax-Academy/kubecon2020
# Kind deployment: https://k8ssandra.io/docs/topics/ingress/traefik/kind-deployment/
# Install And Configure Traefik with Helm: https://traefik.io/blog/install-and-configure-traefik-with-helm/
#
# Port forwarding:
#   8080 - HTTP traffic - This is used for accessing the metrics and repair user interfaces
#   8443 - HTTPS traffic - Useful when accessing the metrics and repair interfaces in a secure manner
#   9000 - Traefik dashboard for development. Higher level environments should use kubectl port-forward.
#   9042 - C* traffic - Insecure Cassandra traffic.
#   9142 - C* TLS traffic - Secure Cassandra traffic, multiple clusters may run behind this single port.
#
# Traefik defaults: https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml
#
# Grafana: http://grafana.localhost:8080/
# Prometheus: http://prometheus.localhost:8080/
# Repair: http://repair.localhost:8080/webui

# Create kind cluster or set GCP cluster
kind delete cluster --name k8ssandra
kind create cluster --name k8ssandra --config ./kind-config-k8ssandra.yaml

helm repo add traefik https://helm.traefik.io/traefik
helm repo add k8ssandra https://helm.k8ssandra.io/
helm repo update

helm install traefik traefik/traefik -n traefik --create-namespace \
  -f traefik-k8ssandra.values.yaml

# Set 'localhost' for kind or an external IP for GCP cluster
export ADDRESS=localhost

helm install k8ss k8ssandra/k8ssandra \
    --set stargate.enabled=true \
    --set ingress.traefik.enabled=true \
    --set ingress.traefik.repair.host=repair.${ADDRESS} \
    --set ingress.traefik.monitoring.grafana.host=grafana.${ADDRESS} \
    --set ingress.traefik.monitoring.prometheus.host=prometheus.${ADDRESS}
