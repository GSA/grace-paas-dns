data "aws_vpc" "frontend" {
  count = var.is_hub ? 0 : 1
  id    = var.vpc_id
}

#find ram resource
data "aws_ram_resource_share" "dns" {
  count          = var.is_hub ? 0 : 1
  name           = "dns"
  resource_owner = "OTHER-ACCOUNTS"

  filter {
    name   = "Environment"
    values = [var.appenv]
  }
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

#associate forwarding rules with VPC
resource "aws_route53_resolver_rule_association" "example" {
  resolver_rule_id = aws_route53_resolver_rule.sys.id
  vpc_id           = aws_vpc.foo.id
}

//dns route53 zone
//dns zone association with vpc association
//dns zone association authorization for hub dns account


//resource "aws_route53_resolver_rule_association" "example" {
//  resolver_rule_id = aws_route53_resolver_rule.sys.id
//  vpc_id           = aws_vpc.foo.id
//}
