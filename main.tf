provider "helm" {
  alias           = "monitoring"
  install_tiller  = false
  service_account = "tiller"
  debug           = true

  kubernetes {
    config_context = "${var.config_context}"
  }
}

provider "kubernetes" {
  alias          = "monitoring"
  config_context = "${var.config_context}"
}

data "aws_route53_zone" "this" {
  name         = "${var.private_zone_name}."
  private_zone = true
}

data "template_file" "grafana_values" {
  template = "${file("${path.module}/templates/grafana_values.yaml.tpl")}"

  vars = {
    password        = "${var.grafana_password}"
    grafana_address = "${aws_route53_record.grafana_ingress.fqdn}"
    prometheus_url  = "http://prometheus-server.monitoring.svc.cluster.local"
  }
}

data "template_file" "prometheus_values" {
  template = "${file("${path.module}/templates/prometheus_values.yaml.tpl")}"
}

resource "helm_release" "grafana" {
  provider  = "helm.monitoring"
  name      = "grafana"
  chart     = "stable/grafana"
  namespace = "${var.namespace}"

  values = ["${data.template_file.grafana_values.rendered}"]

  depends_on = ["helm_release.prometheus"]
}

resource "helm_release" "grafana_ingress" {
  provider  = "helm.monitoring"
  name      = "grafana-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "${var.namespace}"

  values = [
    "${file("${path.module}/templates/ingress_values.yaml.tpl")}",
  ]
}

data "kubernetes_service" "ingress" {
  provider = "kubernetes.monitoring"

  metadata {
    name      = "${helm_release.grafana_ingress.name}-nginx-ingress-controller"
    namespace = "${helm_release.grafana_ingress.namespace}"
  }
}

data "aws_lb" "grafana_ingress" {
  name = "${element(split("-", data.kubernetes_service.ingress.load_balancer_ingress.0.hostname),0)}"
}

resource "aws_route53_record" "grafana_ingress" {
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  name    = "grafana.${var.private_zone_name}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.grafana_ingress.dns_name}"
    zone_id                = "${data.aws_lb.grafana_ingress.zone_id}"
    evaluate_target_health = false
  }
}

resource "helm_release" "prometheus" {
  provider  = "helm.monitoring"
  name      = "prometheus"
  chart     = "stable/prometheus"
  namespace = "${var.namespace}"

  values = ["${data.template_file.prometheus_values.rendered}"]
}
