# Nat Gateway
# Create an Elastic IP
resource "aws_eip" "nat"  {
	vpc = true
	tags = {
    	Name = "DevOps-EIP"
  	}
}

# Create a NAT Gateway and assign it to the subnet
resource  "aws_nat_gateway" "DevOps-NatGW" {
	allocation_id = aws_eip.nat.id
	subnet_id = aws_subnet.public-a.id
	depends_on = ["aws_internet_gateway.DevOps-IGW"]
	tags = {
    	Name = "DevOps-NatGW"
  	}
}