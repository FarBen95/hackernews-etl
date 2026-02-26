resource "aws_security_group" "backend_sg" {
  name = "${var.project}-backend-instance-sg"
  description = "Allow instance to connect to internet and other AWS services"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_egress_rule" "backend_sg_egress_rule" {
  security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# resource "aws_security_group" "redshift_sg" {
#   name = "${var.project}-redshift-sg"
#   description = "Allow Redshift to connect to backend instance and other AWS services"
#   vpc_id = aws_vpc.vpc.id
# }