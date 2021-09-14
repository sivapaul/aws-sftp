variable "account" {
  description = "The 3 letter code for the Organisation AWS account"
  default     = "AAA"
}

variable "account_id" {
  description = "AWS Account Id"
  default     = ""
}

variable    "environment" {
  description ="Environment name"
  default = "Dev"
} 

variable    "vpc_id"  {
  description ="VPC id"
  default = ""
}

variable    "market" {
  description =""
  default = "Finance"
} 

variable    "owner" {
  description =""
  default = "Finance"
}

variable    "product" {
  description =""
  default = "GoAnywhere"
}

variable "private_subnet_a" {
  description = "Subnet A"
}

variable "private_subnet_b" {
  description = "Subnet B"
}

variable "private_subnet_c" {
  description = "Subnet C"
}

variable "public_subnet_a" {
  description = "Public sbnet A"
}

variable "public_subnet_b" {
  description = "Public sbnet B"
}

variable "public_subnet_c" {
  description = "Public sbnet C"
}

variable "cidr_vpc" {
  description  = "VPC cidr range"
}

variable "cidr_private_a" {
  description  = "CIDR range of zone-a private subnet"
}

variable "cidr_public_a"  {
  description  = "CIDR range of zone-a public subnet"
}

variable "cidr_private_b" {
  description  = "CIDR range of zone-b private subnet"
}

variable "cidr_public_b"  {
  description  = "CIDR range of zone-b public subnet"
}

variable "cidr_private_c" {
  description  = "CIDR range of zone-c private subnet"
}

variable "cidr_public_c"  {
  description  = "CIDR range of zone-c public subnet"
}
