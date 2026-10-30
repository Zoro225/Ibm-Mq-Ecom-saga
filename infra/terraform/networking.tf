data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

locals {
  subnets = {
    public_a = {
      cidr = "10.20.1.0/24"
      az   = "us-east-1a"
      tier = "public"
    }
    public_b = {
      cidr = "10.20.2.0/24"
      az   = "us-east-1b"
      tier = "public"
    }
    app_a = {
      cidr = "10.20.11.0/24"
      az   = "us-east-1a"
      tier = "app"
    }
    app_b = {
      cidr = "10.20.12.0/24"
      az   = "us-east-1b"
      tier = "app"
    }
    db_a = {
      cidr = "10.20.21.0/24"
      az   = "us-east-1a"
      tier = "db"
    }
    db_b = {
      cidr = "10.20.22.0/24"
      az   = "us-east-1b"
      tier = "db"
    }
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.tier == "public"

  tags = {
    Name    = "${var.project_name}-${each.key}"
    Tier    = each.value.tier
    Project = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    public_a = aws_subnet.main["public_a"].id
    public_b = aws_subnet.main["public_b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = {
    app_a = aws_subnet.main["app_a"].id
    app_b = aws_subnet.main["app_b"].id
    db_a  = aws_subnet.main["db_a"].id
    db_b  = aws_subnet.main["db_b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}
