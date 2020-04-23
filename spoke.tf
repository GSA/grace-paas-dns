data "aws_caller_identity" "receiver" {}

//resource "aws_ram_resource_share_accepter" "receiver_accept" {
//  share_arn = aws_ram_principal_association.sender_invite.resource_share_arn
//}

#find ram resource
data "aws_ram_resource_share" "tgw" {
  name           = var.tgw_name
  resource_owner = "OTHER-ACCOUNTS"

  filter {
    name = "Environment"
    values = [var.appenv]
  }
}

#associate forwarding rules with VPC
resource "aws_route53_resolver_rule_association" "example" {
  resolver_rule_id = "${aws_route53_resolver_rule.sys.id}"
  vpc_id           = "${aws_vpc.foo.id}"
}

//dns route53 zone
//dns zone association with vpc association
//dns zone association authorization for hub dns account


//resource "aws_route53_resolver_rule_association" "example" {
//  resolver_rule_id = "${aws_route53_resolver_rule.sys.id}"
//  vpc_id           = "${aws_vpc.foo.id}"
//}