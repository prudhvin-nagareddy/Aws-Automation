#VPC
# Create a VPC to launch our instances into
resource "aws_vpc" "DevOps-VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "DevOps-VPC"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "DevOps-IGW" {
  vpc_id = aws_vpc.DevOps-VPC.id
  tags = {
    Name = "DevOps-IGW"
  }
}

#Create Two Private Subnets and Two Public Subnets in Different availability zones
resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.DevOps-VPC.id
  availability_zone = "ap-south-1a"
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Public-Subnet-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.DevOps-VPC.id
  availability_zone = "ap-south-1b"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Public-Subnet-b"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.DevOps-VPC.id
  availability_zone = "ap-south-1a"
  cidr_block        = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  tags =  {
    Name = "Private-Subnet-a"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.DevOps-VPC.id
  availability_zone = "ap-south-1b"
  cidr_block        = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "Private-Subnet-b"
  }
}

# Create a Public Route Table
resource "aws_route_table" "DevOps-Public-RT" {
  vpc_id         = aws_vpc.DevOps-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevOps-IGW.id  
  }
  tags = {
    Name = "DevOps-Public-RT"
  }
} 
  
#Route Associations for Public Route Table
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.DevOps-Public-RT.id
}
resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.DevOps-Public-RT.id
}

# Create a Private Route Table
resource "aws_route_table" "DevOps-Private-RT" {
  vpc_id         = aws_vpc.DevOps-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.DevOps-NatGW.id  
  }
  tags = {
    Name = "DevOps-Private-RT"
  }
} 

#Route Associations for Private Route Table
resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.DevOps-Private-RT.id
}
resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.DevOps-Private-RT.id
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "DevOps-EC2-SG" {
  name        = "DevOps-EC2-SG"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.DevOps-VPC.id
  tags = {
    Name = "DevOps-EC2-SG"
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
