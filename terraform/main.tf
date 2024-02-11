# Basic terraform configuration

provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36.0"
    }
  }
}

# Create a VPC, subnet, rtb and igw

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.61.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf_subnet1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.61.1.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "tf_subnet1"
  }
}

resource "aws_route_table" "tf_rtb" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-rtb"
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
    Name = "tf-igw"
  }
}

# Generate key pair

resource "aws_key_pair" "tf_keypair1" {
  key_name   = "tf_keypair"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Create a security group

resource "aws_security_group" "tf_sg1" {
  name        = "tf-sg1"
  description = "Allow inbound ssh and http traffic"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf-sg1"
  }
}

# Create EC2 instance

resource "aws_instance" "tf_instance1" {
  ami                    = "ami-089c89a80285075f7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf_subnet1.id
  key_name               = aws_key_pair.tf_keypair1.key_name
  user_data              = file("godutch.sh")
  vpc_security_group_ids = [aws_security_group.tf_sg1.id]
  tags = {
    Name = "tf_instance1"
  }
}

# Create an Elastic IP

resource "aws_eip" "tf_eip1" {
  domain = "vpc"
}

resource "aws_eip_association" "tf_eip_assoc1" {
  instance_id   = aws_instance.tf_instance1.id
  allocation_id = aws_eip.tf_eip1.id
}

# Create a Route53 A-record

resource "aws_route53_record" "tfdemo_a_record" {
  zone_id = "Z05656452IRLWUW60U3G4"
  name    = "tfdemo.awscloudqstars.nl"
  type    = "A"
  ttl     = 60
  records = [aws_eip.tf_eip1.public_ip]
}
