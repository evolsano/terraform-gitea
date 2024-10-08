terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}

provider "aws" {
    region = "ap-southeast-1"
  
}

resource "aws_security_group" "cog_sg" {
  vpc_id = aws_vpc.cog_vpc.id
  name = "COG SG"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "wkl-cognixus-key" {
  key_name   = "wkl-cognixus"
  public_key = file("~/.ssh/cognixus.pub") # Path to your public key file
}

resource "aws_instance" "gitea_ec2" {
  ami           = "ami-060e277c0d4cce553" #Ubuntu Server 24.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.cog_pub_subnet_1a.id
  key_name      = aws_key_pair.wkl-cognixus-key.key_name
  #security_groups = [aws_security_group.cog_sg.name]
  vpc_security_group_ids = [aws_security_group.cog_sg.id]

  user_data = file("install_docker.sh")

  tags = {
    Name = "Gitea-Server"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.gitea_ec2.public_ip
}