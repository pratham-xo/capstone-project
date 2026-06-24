resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
}

#Public Subnets
resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "ap-south-1a"
  cidr_block = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  tags ={
    Name = "Web_Subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "ap-south-1b"
  cidr_block = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "Web_Subnet2"
  }
}

#Internet gateway for public subnets this will serve users to access app through public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "IGW"
  }
}

#Associate route table to internet gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Public Route Associations 
resource "aws_route_table_association" "Public_route_subnet1" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "Public_route_subnet2" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public_route_table.id
}

#Now setting up private subnets
resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.private_subnet1_cidr
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.private_subnet2_cidr
  availability_zone = "ap-south-1b"
}

#Elastic ip required for nat gateway
resource "aws_eip" "Elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "Elastic Ip"
  }
}

#Nat gateway for private instances to access internet using elastic ip and igw
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.Elastic_ip.id
  subnet_id = aws_subnet.public1.id
 tags = {
   Name = "Nat Gateway"
 }
  depends_on = [ aws_internet_gateway.igw ]
}

#Associate route table for Nat gateway
resource "aws_route_table" "Nat_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  } 
}

resource "aws_subnet" "db_subnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.db_subnet1_cidr
  availability_zone = "ap-south-1a"
 tags ={
  Name = "Db_subnet1"
 } 
}

resource "aws_subnet" "db_subnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.db_subnet2_cidr
  availability_zone = "ap-south-1b"
  tags ={
  Name = "Db_subnet2"
 } 
}

#Private Table association with private subnets 
resource "aws_route_table_association" "private_route1" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.Nat_route_table.id
}

resource "aws_route_table_association" "private_route2" {
  subnet_id = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.Nat_route_table.id
}

resource "aws_route_table_association" "db_route" {
  subnet_id = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.Nat_route_table.id
}

resource "aws_route_table_association" "db_route2" {
  subnet_id = aws_subnet.db_subnet2.id
  route_table_id = aws_route_table.Nat_route_table.id
}

