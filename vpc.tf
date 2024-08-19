#Create new VPC
resource "aws_vpc" "cog_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "cog-vpc"
  }
}

#Create public subnet 1
resource "aws_subnet" "cog_pub_subnet_1a" {
  vpc_id     = aws_vpc.cog_vpc.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch=true

  tags = {
    Name = "Cog-Public-Subnet_1a"
  }
}

#Create public subnet 2
resource "aws_subnet" "cog_pub_subnet_1b" {
  vpc_id     = aws_vpc.cog_vpc.id

  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch=true

  tags = {
    Name = "Cog-Public-Subnet_1b"
  }
}

#Create private subnet 1a
resource "aws_subnet" "cog_pri_subnet_1a" {
  vpc_id     = aws_vpc.cog_vpc.id

  cidr_block = "10.0.11.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Cog-Private-Subnet-1a"
  }
}

#Create private subnet 1b
resource "aws_subnet" "cog_pri_subnet_1b" {
  vpc_id     = aws_vpc.cog_vpc.id

  cidr_block = "10.0.12.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "Cog-Private-Subnet-1b"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "cog_igw" {
  vpc_id = aws_vpc.cog_vpc.id

  tags = {
    Name = "IGW"
  }
}

#Create routing table
resource "aws_route_table" "cog_rt" {
  vpc_id = aws_vpc.cog_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cog_igw.id
  }

  tags = {
    Name = "cog_route_table"
  }
}

#Create association table
resource "aws_route_table_association" "cog_rt_assoc_pub_1a" {
  subnet_id      = aws_subnet.cog_pub_subnet_1a.id
  route_table_id = aws_route_table.cog_rt.id
}

#Create association table
resource "aws_route_table_association" "cog_rt_assoc_pub_1b" {
  subnet_id      = aws_subnet.cog_pub_subnet_1b.id
  route_table_id = aws_route_table.cog_rt.id
}