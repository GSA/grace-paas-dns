data "aws_vpc" "frontend" {
  count = var.is_hub ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnet" "frontend_a" {
  count      = var.is_hub ? 1 : 0
  cidr_block = cidrsubnet(data.aws_vpc.frontend.cidr_block, 2, 1)
}

data "aws_subnet" "frontend_b" {
  count      = var.is_hub ? 1 : 0
  cidr_block = cidrsubnet(data.aws_vpc.frontend.cidr_block, 2, 2)
}

resource "aws_route53_zone" "internal" {
  name = var.internal_domain

  vpc {
    vpc_id = data.aws_vpc.frontend.id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_ram_resource_share" "dns" {
  count                     = var.is_hub ? 1 : 0
  name                      = "dns"
  allow_external_principals = false

  tags = {
    Environment = var.appenv
  }
}

resource "aws_ram_resource_association" "internal_rule" {
  count              = var.is_hub ? 1 : 0
  resource_arn       = aws_route53_resolver_rule.forward_internal[0]
  resource_share_arn = aws_ram_resource_share.dns[0]
}

resource "aws_ram_resource_association" "external_rule" {
  count              = var.is_hub ? 1 : 0
  resource_arn       = aws_route53_resolver_rule.forward_external[0]
  resource_share_arn = aws_ram_resource_share.dns[0]
}

resource "aws_security_group" "dns" {
  count       = var.is_hub ? 1 : 0
  name        = "dns"
  description = "Allow 53 tcp/udp inbound to VPC"
  vpc_id      = data.aws_vpc.frontend[0].id

  ingress {
    description = "53/tcp from VPC"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }

  ingress {
    description = "53/udp from VPC"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_resolver_endpoint" "internal" {
  count     = var.is_hub ? 1 : 0
  name      = "internal"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.dns[0].id]

  ip_address {
    subnet_id = data.aws_subnet.frontend_a[0].id
  }

  ip_address {
    subnet_id = data.aws_subnet.frontend_b[0].id
  }

  tags {
    Environment = var.appenv
  }
}

resource "aws_route53_resolver_endpoint" "external" {
  count     = var.is_hub ? 1 : 0
  name      = "external"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.dns[0].id]

  ip_address {
    subnet_id = data.aws_subnet.frontend_a[0].id
  }

  ip_address {
    subnet_id = data.aws_subnet.frontend_b[0].id
  }
}

resource "aws_route53_resolver_rule" "forward_internal" {
  count                = var.is_hub ? 1 : 0
  domain_name          = var.internal_domain
  name                 = "forward-inbound"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.internal[0].id

  target_ip {
    ip = aws_route53_resolver_endpoint.internal[0].ip_address
  }
}


resource "aws_route53_resolver_rule" "forward_external" {
  count                = var.is_hub ? 1 : 0
  domain_name          = var.external_domain
  name                 = "forward-outbound"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.external[0].id

  target_ip {
    ip = var.external_dns_server
  }
}
