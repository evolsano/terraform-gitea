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
  name = "COG SG"
  
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
  key_name   = "wkl-cognixus2"
  public_key = file("~/.ssh/cognixus.pub") # Path to your public key file
}

resource "aws_instance" "gitea-ec2" {
  ami           = "ami-060e277c0d4cce553" #Ubuntu Server 24.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.wkl-cognixus-key.key_name
  security_groups = [aws_security_group.cog_sg.name]

  tags = {
    Name = "Gitea-Server"
  }

  #Provision the script
  provisioner "file" {
    source = "install_docker.sh"
    destination = "/home/ubuntu/install_docker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install_docker.sh"
     ]
  }
}