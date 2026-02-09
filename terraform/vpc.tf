resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "${var.public_subnet_cidr}"
  tags = {
    Name = "${var.project}-subnet-public"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "${var.private_subnet_cidr}"
  tags = {
    Name = "${var.project}-subnet-private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "${var.project}-eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  vpc_id = aws_vpc.vpc.id
  availability_mode = "regional"

  tags = {
    Name = "${var.project}-ngw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-rtb-public"
  }
}

resource "aws_route_table_association" "public_rtba" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${var.project}-rtb-private"
  }
}

resource "aws_route_table_association" "private_rtba" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_vpc_endpoint" "s3_vpce" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rtb.id]
  tags = {
    Name = "${var.project}-vpce-s3"
  }
}