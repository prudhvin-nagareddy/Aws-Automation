# Create a VPC to launch our instances into
resource "aws_vpc" "DevOps-VPC" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    Name = "DevOps-VPC"
  }
}

#Create Two Public Subnets in Different availability zones
resource "aws_subnet" "public-subnet" {
  vpc_id     = "${aws_vpc.DevOps-VPC.id}"
  count      = "${length(var.public_subnets_cidr)}"
  cidr_block = "${element(var.public_subnets_cidr,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "DevOps-Public-Subnet${count.index + 1}"
  }
}

#Create Two Private Subnets in Different availability zones
resource "aws_subnet" "private-subnet" {
  vpc_id     = "${aws_vpc.DevOps-VPC.id}"
  count      = "${length(var.private_subnets_cidr)}"
  cidr_block = "${element(var.private_subnets_cidr,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "DevOps-Private-Subnet${count.index + 1}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "DevOps-IGW" {
  vpc_id = "${aws_vpc.DevOps-VPC.id}"
  tags = {
    Name = "DevOps-IGW"
  }
}

# Create  Public Route table and provide Internet access via Internet Gateway
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

# Create a Private Route table and provide Interbet access via Nat-Instance
resource "aws_route_table" "DevOps-Private-RT" {
  vpc_id = aws_vpc.DevOps-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.DevOps-Nat.id}" 
  }
  tags = {
    Name = "DevOps-Private-RT"
  }
  depends_on = [aws_instance.DevOps-Nat]
}

#Assocoaite the Public Subnets to the Pubilc Route Table
resource "aws_route_table_association" "a" {
  count = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id,count.index)}"
  route_table_id = "${aws_route_table.DevOps-Public-RT.id}"
}

#Assocoaite the Private Subnets to the Private Route Table
resource "aws_route_table_association" "b" {
  count = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private-subnet.*.id,count.index)}"
  route_table_id = "${aws_route_table.DevOps-Private-RT.id}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "DevOps-ELB-SG" {
  name        = "DevOps-ELB-SG"
  description = "Used in the terraform for ELB access"
  vpc_id      = "${aws_vpc.DevOps-VPC.id}"
  tags = {
    Name = "DevOps-ELB-SG"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
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

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "DevOps-EC2-SG" {
  name        = "DevOps-EC2-SG"
  description = "Used in the terraform for Ec2 access"
  vpc_id      = "${aws_vpc.DevOps-VPC.id}"
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