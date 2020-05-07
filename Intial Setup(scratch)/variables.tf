#variable "public_key_path" {
#  description = <<DESCRIPTION
#Path to the SSH public key to be used for authentication.
#Ensure this keypair is added to your local SSH agent so provisioners can connect.

#Example: ~/.ssh/terraform.pub
#DESCRIPTION
#
#}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "access_key" {
  description = "Access Key to access the AWS Account"
}

variable "secret_key" {
  description = "  Secret Key to the AWS Account"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-south-1"
}

# Ubuntu Precise 18.04 LTS (x64)
variable "aws_amis" {
  default = {
    ap-south-1 = "ami-0620d12a9cf777c87"
    eu-west-1  = "ami-674cbc1e"
    us-east-1  = "ami-1d4e7a66"
    us-west-1  = "ami-969ab1f6"
    us-west-2  = "ami-8803e0f0"
  }
}

#VPC CIDR Block
#variable "vpc_cidr" {
 # default = "10.10.0.0/16"
#}

# Public Subnet Cidr Block
#variable "public_subnets_cidr" {
 # type    = list(string)
 #default = ["10.10.1.0/24", "10.10.2.0/24"]
#}

# Private Subnet Cidr Block
#variable "private_subnets_cidr" {
#  type    = list(string)
#  default = ["10.10.3.0/24", "10.10.4.0/24"]
#}

# Availability Zones
#variable "azs" {
#  type    = list(string)
#  default = ["ap-south-1a", "ap-south-1b"]
#}

