# -----------------------------------------------------------------------------
# 1. Virtual Private Cloud (VPC) Creation
# -----------------------------------------------------------------------------
# This resource creates a logically isolated virtual network (VPC) in your AWS account.
resource "aws_vpc" "main" {
  # The primary IPv4 address range for the VPC.
  cidr_block           = "10.0.0.0/16"
  # Ensures that instances launched in the VPC get a DNS hostname.
  enable_dns_hostnames = true
  # Ensures that the Amazon-provided DNS server can resolve DNS hostnames.
  enable_dns_support   = true

  # A tag to easily identify the VPC in the AWS console.
  tags = {
    Name = "TechStore-VPC"
  }
}

# -----------------------------------------------------------------------------
# 2. Subnets Creation
# -----------------------------------------------------------------------------
# Subnets are subdivisions of the VPC's IP address range, tied to a specific Availability Zone.

# Public Subnet in Availability Zone 'a'
resource "aws_subnet" "public_a" {
  # Associates the subnet with the main VPC.
  vpc_id                          = aws_vpc.main.id
  # Specifies the Availability Zone for this subnet. Using a variable for region makes the code more reusable.
  availability_zone               = "${var.aws_region}a"
  # The specific IP address range for this subnet, carved out from the main VPC CIDR.
  cidr_block                      = "10.0.1.0/24"
  # Automatically assigns a public IP address to instances launched in this subnet.
  map_public_ip_on_launch = true

  tags = {
    Name = "TechStore-VPC-subnet-public1-us-east-1a"
  }
}

# Public Subnet in Availability Zone 'b' for high availability.
resource "aws_subnet" "public_b" {
  vpc_id                          = aws_vpc.main.id
  availability_zone               = "${var.aws_region}b"
  cidr_block                      = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TechStore-VPC-subnet-public2-us-east-1b"
  }
}

# Private Subnet in Availability Zone 'a'. Instances here won't have public IPs.
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}a"
  cidr_block        = "10.0.11.0/24"

  tags = {
    Name = "TechStore-VPC-subnet-private1-us-east-1a"
  }
}

# Private Subnet in Availability Zone 'b' for placing backend resources like databases.
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}b"
  cidr_block        = "10.0.12.0/24"

  tags = {
    Name = "TechStore-VPC-subnet-private1-us-east-1b"
  }
}

# -----------------------------------------------------------------------------
# 3. Internet Gateway (IGW) Creation
# -----------------------------------------------------------------------------
# The IGW allows communication between resources in your VPC and the internet.
resource "aws_internet_gateway" "main" {
  # Attaches the Internet Gateway to our main VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TechStore-VPC-igw"
  }
}

# -----------------------------------------------------------------------------
# 4. Public Route Table Creation
# -----------------------------------------------------------------------------
# A route table contains rules that determine where network traffic is directed.

# This route table is for public subnets.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  # This route sends all outbound traffic (0.0.0.0/0) to the Internet Gateway.
  # This is what makes a subnet "public".
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "TechStore-VPC-rtb-public"
  }
}

# Associate the public subnets with the public route table.
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# 5. Private Route Table Creation
# -----------------------------------------------------------------------------
# These route tables are for private subnets. By default, they can only route traffic
# within the VPC. To give them internet access, a NAT Gateway would be needed.

# Private Route Table for subnets in Availability Zone 'a'.
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TechStore-VPC-rtb-private1-us-east-1a"
  }
}

# Associates the private subnet 'a' with its corresponding route table.
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# Private Route Table for subnets in Availability Zone 'b'.
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TechStore-VPC-rtb-private2-us-east-1b"
  }
}

# Associates the private subnet 'b' with its corresponding route table.
resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
