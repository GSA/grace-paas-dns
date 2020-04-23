resource "aws_ram_resource_share" "dns_share" {
  name                      = "dns-resource-share"
  allow_external_principals = false

  tags = {
    Environment = var.appenv
  }
}

resource "aws_ram_principal_association" "example" {
  principal          = "${aws_organizations_organization.example.arn}"
  resource_share_arn = "${aws_ram_resource_share.example.arn}"
}

resource "aws_ram_resource_association" "example" {
  resource_arn       = aws_route53_resolver_rule.forward_inbound
  resource_share_arn = aws_ram_resource_share.dns_share
}

resource "aws_ram_resource_association" "example2" {
  resource_arn       = aws_route53_resolver_rule.forward_outbound
  resource_share_arn = aws_ram_resource_share.dns_share
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "inbound"
  direction = "INBOUND"

  security_group_ids = [
    "${aws_security_group.sg1.id}",
    "${aws_security_group.sg2.id}",
  ]

  ip_address {
    subnet_id = "${aws_subnet.sn1.id}"
  }

  ip_address {
    subnet_id = "${aws_subnet.sn2.id}"
    ip        = "10.0.2.1"
  }

  tags {
    Environment = "Prod"
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name      = "outbound"
  direction = "OUTBOUND"

  security_group_ids = [
    "${aws_security_group.sg1.id}",
    "${aws_security_group.sg2.id}",
  ]

  ip_address {
    subnet_id = "${aws_subnet.sn1.id}"
  }

  ip_address {
    subnet_id = "${aws_subnet.sn2.id}"
    ip        = "10.0.64.4"
  }

  tags {
    Environment = "Prod"
  }
}

resource "aws_route53_resolver_rule" "forward_inbound" {
  domain_name          = "g.gsa.gov"
  name                 = "example1"
  rule_type            = "FORWARD"
  resolver_endpoint_id = "${aws_route53_resolver_endpoint.foo.id}"

  target_ip {
    ip = "123.45.67.89"
  }

  tags {
    Environment = "Prod"
  }
}


resource "aws_route53_resolver_rule" "forward_outbound" {
  domain_name          = "g.gsa.gov"
  name                 = "example1"
  rule_type            = "FORWARD"
  resolver_endpoint_id = "${aws_route53_resolver_endpoint.foo.id}"

  target_ip {
    ip = "124.15.68.99"
  }

  tags {
    Environment = "Prod"
  }
}