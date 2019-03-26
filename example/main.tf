provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "monitoring" {
  source = "../"

  config_context    = "${var.config_context}"
  private_zone_name = "${var.private_zone_name}"
  grafana_password  = "${var.password}"
}

output "grafana_endpoint" {
  value = "${module.monitoring.grafana_endpoint}"
}
