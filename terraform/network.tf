# Create a VPC, subnet, rtb and igw

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.61.0.0/16"
  tags = {
    Name    = "tf-vpc"
    Purpose = "IAC-demo"
  }
}

resource "aws_subnet" "tf_subnet1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.61.1.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name    = "tf_subnet1"
    Purpose = "IAC-demo"
  }
}

resource "aws_route_table" "tf_rtb" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name    = "tf-rtb"
    Purpose = "IAC-demo"
  }
}

resource "aws_route_table_association" "tf_rtb_assoc" {
  subnet_id      = aws_subnet.tf_subnet1.id
  route_table_id = aws_route_table.tf_rtb.id
}

resource "aws_route" "tf_default_gateway" {
  route_table_id         = aws_route_table.tf_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_igw.id
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name    = "tf-igw"
    Purpose = "IAC-demo"
  }
}

