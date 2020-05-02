resource "aws_vpc" "default" {
  cidr_block           = "${local.ip_prefix}${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "lsccraffler-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group" "default" {
  name        = "lsccraffler_sg"
  description = "Allow traffic to pass from and to the internet"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "lsccraffler default security group"
  }
}

resource "aws_subnet" "primary_public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${local.ip_prefix}${var.primary_public_cidr}"
  availability_zone = "eu-west-2a"

  tags {
    Name = "Primary Public Subnet"
  }
}

resource "aws_route_table" "primary_public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Primary Public Subnet"
  }
}

resource "aws_route_table_association" "primary_public" {
  subnet_id      = "${aws_subnet.primary_public.id}"
  route_table_id = "${aws_route_table.primary_public.id}"
}

resource "aws_subnet" "secondary_public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${local.ip_prefix}${var.secondary_public_cidr}"
  availability_zone = "eu-west-2b"

  tags {
    Name = "Secondary Public Subnet"
  }
}

resource "aws_route_table" "secondary_public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Secondary Public Subnet"
  }
}

resource "aws_route_table_association" "secondary_public" {
  subnet_id      = "${aws_subnet.secondary_public.id}"
  route_table_id = "${aws_route_table.secondary_public.id}"
}

resource "aws_eip" "nat" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.203"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.primary_public.id}"

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_subnet" "primary_private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${local.ip_prefix}${var.primary_private_cidr}"
  availability_zone = "eu-west-2a"

  tags {
    Name = "Primary Private Subnet"
  }
}

resource "aws_route_table" "primary_private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "Primary Private Subnet"
  }
}

resource "aws_route_table_association" "primary_private" {
  subnet_id      = "${aws_subnet.primary_private.id}"
  route_table_id = "${aws_route_table.primary_private.id}"
}

resource "aws_subnet" "secondary_private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${local.ip_prefix}${var.secondary_private_cidr}"
  availability_zone = "eu-west-2b"

  tags {
    Name = "Secondary Private Subnet"
  }
}

resource "aws_route_table" "secondary_private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "Secondary Private Subnet"
  }
}

resource "aws_route_table_association" "secondary_private" {
  subnet_id      = "${aws_subnet.secondary_private.id}"
  route_table_id = "${aws_route_table.secondary_private.id}"
}
