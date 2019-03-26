persistence:
  enabled: true
  accessModes:
    - ReadWriteOnce
  size: 5Gi
ingress:
  enabled: true
  hosts:
  - ${grafana_address}
adminPassword: ${password}
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: ${prometheus_url}
      access: proxy