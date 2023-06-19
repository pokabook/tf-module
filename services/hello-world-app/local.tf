locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

locals {
  mysql_config = (
    var.mysql_config == null ? data.terraform_remote_state.db[0].outputs : var.mysql_config
  )
  vpc_id = (
    var.vpc_id == null ? data.aws_vpc.default[0].id : var.vpc_id
  )

  subnet_ids = (
    var.subnet_ids == null ? data.aws_subnets.default[0].ids : var.subnet_ids
  )
}