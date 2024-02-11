# Generate key pair

resource "aws_key_pair" "tf_keypair1" {
  key_name   = "tf_keypair"
  public_key = file("~/.ssh/id_ed25519.pub")
  tags = {
    Name    = "tf_keypair1"
    Purpose = "IAC-demo"
    Author  = "Ernest"
  }
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
    Name    = "tf-sg1"
    Purpose = "IAC-demo"
    Author  = "Ernest"
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
    Name    = "tf_instance1"
    Purpose = "IAC-demo"
    Author  = "Ernest"
  }
}

# Create an Elastic IP

resource "aws_eip" "tf_eip1" {
  domain = "vpc"
  tags = {
    Name    = "tf_eip1"
    Purpose = "IAC-demo"
    Author  = "Ernest"
  }
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
