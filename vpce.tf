sg_inbound_vpce = { 
    rule-vpn =  {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks  = "10.26.46.0/24"
      source_security_group_id = ""
      description = "Allow VPN OnPrem"
    },
    rule-vpn-two =  {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks  = "10.26.60.0/23"
      source_security_group_id = ""
      description = "Allow VPN OnPrem"
    },
    rule-vpn-three =  {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks  = "10.2.0.225/32"
      source_security_group_id = ""
      description = "Allow pfsense vpn private"
    },
  }
  sg_outbound_vpce = {
    rule-es-all =  {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = "0.0.0.0/0"
        source_security_group_id = ""
        description = "Allow All"
      }
    }
  sg_inbound_lambda_api = {}
  sg_outbound_lambda_api = {
    rule-all =  {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = "0.0.0.0/0"
        source_security_group_id = ""
        description = "Allow All"
      }
    }
  sg_inbound_lambda = {}
  sg_outbound_lambda = {
    rule-all =  {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks  = "0.0.0.0/0"
      source_security_group_id = ""
      description = "Allow All"
    }
  }


resource "aws_vpc_endpoint" "this" {
  count       = var.vpce_enabled ? 1 : 0
  vpc_id            = data.aws_vpc.selected.id
  service_name      = var.service_name
  vpc_endpoint_type = var.vpc_endpoint_type
  subnet_ids = var.vpc_endpoint_type == "Interface" ? data.aws_subnet_ids.private.ids : null
  route_table_ids = var.vpc_endpoint_type == "Gateway" ? data.aws_route_tables.selected.ids : null

  security_group_ids = var.vpc_endpoint_type == "Interface" ? [ aws_security_group.vpce_sg[count.index].id, ] : null 

  private_dns_enabled = var.private_dns_enabled

  tags =  merge({
    "Name" = join("-", [local.name, "vpce"])
    },
    local.tags
  )
}

resource "aws_security_group" "vpce_sg" {
  count       = var.vpce_enabled ? 1 : 0
  name        = "${local.name}-vpce-sg"
  description = local.terraform_description
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    iterator = inbound
    for_each = local.sg_inbound_vpce
    content {
      from_port   = inbound.value.from_port
      to_port     = inbound.value.to_port
      protocol    = inbound.value.protocol
      cidr_blocks = inbound.value.source_security_group_id == "" ? [inbound.value.cidr_blocks] : null 
      security_groups = inbound.value.source_security_group_id != "" ? [inbound.value.source_security_group_id] : null
      description  = inbound.value.description
    }
  }

  dynamic "egress" {
    iterator = outbound
    for_each = local.sg_outbound_vpce
    content {
      from_port   = outbound.value.from_port
      to_port     = outbound.value.to_port
      protocol    = outbound.value.protocol
      cidr_blocks = outbound.value.source_security_group_id == "" ? [outbound.value.cidr_blocks] : null 
      security_groups = outbound.value.source_security_group_id != "" ? [outbound.value.source_security_group_id] : null
      description  = outbound.value.description
    }
  }

 lifecycle {
    create_before_destroy = true
  }

 tags = {
    "Name" = "${local.name}-msk-elasticsearch-api-sg"
    }
} 
