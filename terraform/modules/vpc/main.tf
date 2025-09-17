# VPC Creation
resource "aws_vpc" "main" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "TechStore-VPC"
  }
}

# -----------------------------------------------------------------------------
# 2. Subnets Creation
# -----------------------------------------------------------------------------


# Public Subnet 1A
resource "aws_subnet" "public_a" {
  vpc_id                          = aws_vpc.main.id
  availability_zone               = "${var.aws_region}a"
  cidr_block                      = "10.0.1.0/24"
  map_customer_owned_ip_on_launch = true

  tags = {
    Name = "TechStore-VPC-subnet-public1-us-east-1a"
  }
}

# Public Subnet 1B
resource "aws_subnet" "public_b" {
  vpc_id                          = aws_vpc.main.id
  availability_zone               = "${var.aws_region}b"
  cidr_block                      = "10.0.12.0/24"
  map_customer_owned_ip_on_launch = true

  tags = {
    Name = "TechStore-VPC-subnet-public2-us-east-1b"
  }
}

# Private Subnet 1A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}a"
  cidr_block        = "10.0.11.0/24"

  tags = {
    Name = "TechStore-VPC-subnet-private1-us-east-1a"
  }
}

# Private Subnet 1B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}b"
  cidr_block        = "10.0.12.0/24"

  tags = {
    Name = "TechStore-VPC-subnet-private1-us-east-1b"
  }
}

# -----------------------------------------------------------------------------
# 3. Internet Gateway Creation
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TechStore-VPC-igw"
  }

}

# -----------------------------------------------------------------------------
# 4. Public Route Table Creation
# -----------------------------------------------------------------------------

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "TechStore-VPC-rtb-public"
  }
}

# Associate Publics Subnets to the Public Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# 5. Private Route Table Creation
# -----------------------------------------------------------------------------

# Private Route Table 1A ----------------------------
resource "aws_route_table" "private_a" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TechStore-VPC-rtb-private1-us-east-1a"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# -------------------------------------------------------


# Private Route Table 1B ----------------------------
resource "aws_route_table" "private_b" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TechStore-VPC-rtb-private2-us-east-1b"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
# -------------------------------------------------------