# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

## Create the Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.a_z_1
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_1
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.a_z_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_2
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.a_z_1

  tags = {
    Name = var.private_subnet_1
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.a_z_2

  tags = {
    Name = var.private_subnet_2
  }
}

## Internet gateway
resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id


  tags = {
    Name = "igw-name"
  }
}

#route tables public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "public route table name"
  }
}

resource "aws_route" "public_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# Create Elastip ip for Nat
resource "aws_eip" "eip_nat" {
  domain = "vpc"

  tags = {
    Name = "Elastic ip"
  }
}

# Create nat gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

# Route tables private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private route table name"
  }

}

resource "aws_route" "private_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

## Security groups

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow Traffic into ALB"
  vpc_id      = aws_vpc.main.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_http_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow HTTP traffic from the internet to the ALB"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow HTTPS traffic from the internet to the ALB"
}

resource "aws_vpc_security_group_egress_rule" "allow_alb_out" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_security_group" "task_sg" {
  name        = "task-sg"
  description = "Allow Traffic to ecs task"
  vpc_id      = aws_vpc.main.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_alb" {
  security_group_id            = aws_security_group.task_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 5230
  ip_protocol                  = "tcp"
  to_port                      = 5230
  description                  = "Allow ALB traffic to ECS tasks on application port"
}

resource "aws_vpc_security_group_egress_rule" "allow_task_out" {
  security_group_id = aws_security_group.task_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  description       = "Allow ECS tasks outbound access to the internet"
}