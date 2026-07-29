locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "platform-db"
    Layer       = "foundation"
  })

  availability_zones = [
    for suffix in var.availability_zone_suffixes : "${var.aws_region}${suffix}"
  ]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = {
    for index, az in local.availability_zones : az => {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, index)
    }
  }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-public"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = {
    for index, az in local.availability_zones : az => {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, index + length(local.availability_zones))
    }
  }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-private"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-public"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-private"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
