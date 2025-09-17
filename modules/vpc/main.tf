# aws_vpc.this
# Creates a Virtual Private Cloud (VPC), which is a dedicated virtual network for your AWS account.
# Acts as the “container” for all networking resources (subnets, gateways, etc.).
# Enables DNS support and hostnames to allow internal name resolution and access to AWS services by name.
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

# aws_internet_gateway.this
# Creates an Internet Gateway, a component that allows resources within the VPC (e.g., EC2 instances in public subnets) to access the internet.
# The IGW is attached to the VPC and is essential for inbound/outbound connectivity between the VPC and the outside world.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-igw"
  }
}

# aws_subnet.public
# Creates two public subnets within the VPC.
# Each subnet represents an IP address range within the VPC's CIDR block, associated with a specific availability zone.
# With map_public_ip_on_launch enabled, instances launched here will automatically receive a public IP, allowing direct access to/from the internet (if the route table allows it).
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true # Automatically assigns a public IP to instances
  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# aws_subnet.private
# Creates two private subnets within the VPC.
# These subnets do not automatically assign public IPs to instances launched and typically do not have direct internet access.
# Ideal for internal resources (databases, backend servers, etc.).
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr) // Number of private subnets to create
  vpc_id            = aws_vpc.this.id               // ID of the VPC where subnets are created
  cidr_block        = var.private_subnets_cidr[count.index] // Specific CIDR block for each private subnet
  availability_zone = element(var.azs, count.index) // Assigns an availability zone based on the index
  map_public_ip_on_launch = false // Does not automatically assign public IPs to instances
  tags = {
    Name = "${var.name}-private-${count.index + 1}" // Friendly name for the subnet
  }
}

# aws_route_table.public
# Creates a route table that defines how traffic is directed within the VPC.
# This table will be used by public subnets to ensure that outbound traffic to the internet is routed to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-public-rt"
  }
}

# aws_route.public_internet_access
# Adds a route in the public route table so that all traffic destined outside the VPC (0.0.0.0/0) is sent to the Internet Gateway.
# This enables public subnets to access the internet.
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # All IPv4 traffic
  gateway_id             = aws_internet_gateway.this.id
}

# aws_route_table_association.public
# Associates each public subnet with the public route table.
# Explicitly links the subnet with the outbound route to the internet (via the IGW).
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ----------- BLOCKS FOR INTERNET ACCESS FROM PRIVATE SUBNETS -----------

# Elastic IP for the NAT Gateway (required for the NAT to have a public IP)
resource "aws_eip" "nat" {
  tags = {
    Name = "${var.name}-nat-eip"
  }
}

# NAT Gateway in the first public subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.name}-nat-gw"
  }
  depends_on = [aws_internet_gateway.this]
}

# Private route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-private-rt"
  }
}

# Outbound route to the internet in the private route table using the NAT Gateway
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Association of each private subnet with the private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}