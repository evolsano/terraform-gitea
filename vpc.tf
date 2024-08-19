#Create new VPC
resource "aws_vpc" "cog_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "cog-vpc"
  }
}

#Create new subnet
resource "aws_subnet" "cog_pub_subnet" {
  vpc_id     = aws_vpc.cog_vpc.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch=true
  
  tags = {
    Name = "Cog-Public-Subnet"
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

#Create association tab;e
resource "aws_route_table_association" "cog_rt_assoc" {
  subnet_id      = aws_subnet.cog_pub_subnet.id
  route_table_id = aws_route_table.cog_rt.id
}