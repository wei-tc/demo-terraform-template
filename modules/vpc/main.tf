resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    project = var.project_name
  }
}

resource "aws_default_route_table" "main_private" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  dynamic "route" {
    for_each = var.private_routes

    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id
      instance_id = route.value.instance_id
      nat_gateway_id = route.value.nat_gateway_id
    }
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_route_table_association" "main_private" {
  count = length(aws_subnet.private)

  route_table_id = aws_default_route_table.main_private.id
  subnet_id = aws_subnet.private[count.index].id

  depends_on = [
    aws_default_route_table.main_private,
    aws_subnet.public
  ]
}

resource "aws_route_table" "custom_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  dynamic "route" {
    for_each = var.public_routes

    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id
      instance_id = route.value.instance_id
      nat_gateway_id = route.value.nat_gateway_id
    }
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_route_table_association" "custom_public" {
  count = length(aws_subnet.public)

  route_table_id = aws_route_table.custom_public.id
  subnet_id = aws_subnet.public[count.index].id

  depends_on = [
    aws_route_table.custom_public,
    aws_subnet.private]
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    project = var.project_name
  }
}

resource "aws_security_group" "private" {
  name = "${var.project_name}-private-sg"

  description = "RDS"
  vpc_id = aws_vpc.main.id

  tags = {
    project = var.project_name
    private = true
  }
}

resource "aws_security_group_rule" "private_ingress" {
  description = "RDS"
  type = "ingress"
  from_port = var.rds_port
  to_port = var.rds_port
  protocol = "tcp"
  security_group_id = aws_security_group.private.id
  source_security_group_id = aws_security_group.public.id
}

resource "aws_security_group" "public" {
  name = "${var.project_name}-public-sg"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    project = var.project_name
    public = true
  }
}

resource "aws_security_group_rule" "public_egress" {
  description = "RDS"
  type = "egress"
  from_port = var.rds_port
  to_port = var.rds_port
  protocol = "tcp"
  security_group_id = aws_security_group.public.id
  source_security_group_id = aws_security_group.private.id
}

resource "aws_ssm_parameter" "public_sg_id" {
  name = "/vpc/${var.project_name}/public/sg/id"
  type = "SecureString"
  value = aws_security_group.public.id
  overwrite = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  count = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    project = var.project_name
    private = true
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    project = var.project_name
    public = true
  }
}

resource "aws_ssm_parameter" "public_subnet_1_id" {
  name = "/vpc/${var.project_name}/public/subnet/1/id"
  type = "SecureString"
  value = aws_subnet.public[0].id
  overwrite = true
}

resource "aws_ssm_parameter" "public_subnet_2_id" {
  name = "/vpc/${var.project_name}/public/subnet/2/id"
  type = "SecureString"
  value = aws_subnet.public[1].id
  overwrite = true
}
