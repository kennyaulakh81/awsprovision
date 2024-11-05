# create Windows Instance using ami-0b738b7295e3be0a4 
# open port for both windows and linux machine to access default html file
# for ubuntu server add a user data script to print hostname at public ip address

output "ubuntu_public_ip" {
  value = aws_instance.ubuntu_server.public_ip
}

provider "aws" {
  region = "eu-west-2"
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "key_name" {
  default = "kp01"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CustomVPC"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "CustomInternetGateway"
  }
}

resource "aws_subnet" "tf_public_subnet" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "CustomPublicSubnet"
  }
}

resource "aws_route_table" "tf_route_table" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "CustomPublicRouteTable"
  }
}

resource "aws_route_table_association" "tf_route_table_assoc" {
  subnet_id      = aws_subnet.tf_public_subnet.id
  route_table_id = aws_route_table.tf_route_table.id
}

resource "aws_instance" "ubuntu_server" {
  ami                     = "ami-0acc77abdfc7ed5a6" 
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.tf_public_subnet.id
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.tf_sg.id]  

  tags = {
    Name = "CustomUbuntuServer"
  }
}

resource "aws_security_group" "tf_sg" {
  vpc_id = aws_vpc.tf_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
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
    Name = "CustomSecurityGroup"
  }
}
