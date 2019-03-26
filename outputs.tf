output "grafana_endpoint" {
  value = "${aws_route53_record.grafana_ingress.fqdn}"
}
