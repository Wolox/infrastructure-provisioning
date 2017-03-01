resource "aws_vpc" "stage" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "stage" {
  vpc_id = "${aws_vpc.stage.id}"
}

# Public subnets

resource "aws_subnet" "us-east-1b-public" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "us-east-1d-public" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1d"
}

# Routing table for public subnets

resource "aws_route_table" "us-east-1-public" {
  vpc_id = "${aws_vpc.stage.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.stage.id}"
  }
}

resource "aws_route_table_association" "us-east-1b-public" {
  subnet_id = "${aws_subnet.us-east-1b-public.id}"
  route_table_id = "${aws_route_table.us-east-1-public.id}"
}

resource "aws_route_table_association" "us-east-1d-public" {
  subnet_id = "${aws_subnet.us-east-1d-public.id}"
  route_table_id = "${aws_route_table.us-east-1-public.id}"
}

# Private subsets

resource "aws_subnet" "us-east-1b-private" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "us-east-1d-private" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1d"
}
