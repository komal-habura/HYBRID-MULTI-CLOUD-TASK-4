provider "aws" {
  version = "~> 2.70.0"
  region  = "ap-south-1"
}


resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.1.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/25"

  tags = {
    Name = "public-subnet"
  }
}
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.128/25"
  tags = {
    Name = "private-subnet"
  }
}
//create internet gatway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "gw"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-RT.id
}

//route table
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-RT"
  }
}

resource "aws_nat_gateway" "NATgw" {
  allocation_id = "eipalloc-0e490ddb78ce4f807"
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NATgw"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-RT.id
}

resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }

  tags = {
    Name = "private-RT"
  }
}
