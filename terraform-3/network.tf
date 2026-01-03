# --- VPC & Internet Gateway ---
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "ig"
  }
}

# --- Public Subnets ---
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-2b"
  tags = {
    Name = "public-subnet-2"
  }
}

# --- Private Subnets ---
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-southeast-2b"
  tags = {
    Name = "private-subnet-2"
  }
}

# --- NAT Gateways ---
resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}
resource "aws_nat_gateway" "ng_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
}
resource "aws_nat_gateway" "ng_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
}

# --- Public Routing ---
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-rt-public"
  }
}

resource "aws_route" "ig_rt_public" {
  route_table_id         = aws_route_table.my_rt.id
  gateway_id             = aws_internet_gateway.ig.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rt_pub_asc" {
  count          = 2
  subnet_id      = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id][count.index]
  route_table_id = aws_route_table.my_rt.id
}

# --- Private Routing (AZ 1) ---
resource "aws_route_table" "my_rt_private_1" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-rt-private-1"
  }
}

resource "aws_route" "nat_rt_private_1" {
  route_table_id         = aws_route_table.my_rt_private_1.id
  nat_gateway_id         = aws_nat_gateway.ng_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rt_priv_asc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.my_rt_private_1.id
}

# --- Private Routing (AZ 2) ---
resource "aws_route_table" "my_rt_private_2" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-rt-private-2"
  }
}

resource "aws_route" "nat_rt_private_2" {
  route_table_id         = aws_route_table.my_rt_private_2.id
  nat_gateway_id         = aws_nat_gateway.ng_2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rt_priv_asc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.my_rt_private_2.id
}
