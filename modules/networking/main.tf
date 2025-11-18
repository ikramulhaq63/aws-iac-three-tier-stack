resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = {
        Name = "${var.project_name}-vpc"
    }
}
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-web_igw"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_1_cidr
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_2_cidr
    availability_zone = var.availability_zone_2
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.project_name}-public-subnet-2"
    }
}
resource "aws_subnet" "private_app_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_1_app_cidr
    availability_zone = var.availability_zone_1
    tags = {
      Name = "${var.project_name}-private-subnet-1-app-tier"
    }
}
resource "aws_subnet" "private_app_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_2_app_cidr
    availability_zone = var.availability_zone_2
    tags = {
      Name = "${var.project_name}-private-subnet-2-app-tier"
    }
}
resource "aws_subnet" "private_db_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_1_db_cidr
    availability_zone = var.availability_zone_1
    tags = {
      Name = "${var.project_name}-private-subnet-1-db-tier"
    }
}
resource "aws_subnet" "private_db_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_2_db_cidr
    availability_zone = var.availability_zone_2
    tags = {
      Name = "${var.project_name}-private-subnet-2-db-tier"
    }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}
resource "aws_main_route_table_association" "main_route_table" {
    vpc_id = aws_vpc.main.id
    route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_route_table_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_route_table_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_eip" "Nat-Gatway-ip" {
    domain = "vpc"
    tags = {
      Name = "${var.project_name}-elastic-ip"
    }
  depends_on = [ aws_internet_gateway.web_igw ]
}
resource "aws_nat_gateway" "Nat_Gateway_for_Private_instances" {
  allocation_id = aws_eip.Nat-Gatway-ip.id
  subnet_id = aws_subnet.public_subnet_1.id
  tags = {
    Name = "${var.project_name}-Nat-Gateway"
  }
  depends_on = [ aws_internet_gateway.web_igw ]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat_Gateway_for_Private_instances.id

  }
  tags = {
    Name = "${var.project_name}-route-table-for private-instances"
  }
}

resource "aws_route_table_association" "private_route_table_app_1" {
  subnet_id      = aws_subnet.private_app_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_route_table_app_2" {
  subnet_id      = aws_subnet.private_app_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_route_table_db_1" {
  subnet_id      = aws_subnet.private_db_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_route_table_db_2" {
  subnet_id      = aws_subnet.private_db_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}