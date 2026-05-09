## create rds subnet group
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "memos-rds-subnet-group"
  subnet_ids = [var.private_subnet_1_id, var.private_subnet_2_id]


}

## create DB security group
resource "aws_security_group" "rds_sg" {
  name        = "db-sg"
  description = "Allow traffic to RDS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "DB security group"
  }
}


# Create DB ingress and egress rules
resource "aws_vpc_security_group_ingress_rule" "rds_in" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.task_sg
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "Allow PostgreSQL traffic from ECS tasks to RDS"
}

resource "aws_vpc_security_group_egress_rule" "rds_out" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  description = "Allow outbound traffic from RDS security group"
}

## create DB postgress
resource "aws_db_instance" "postgres_db" {
  identifier              = "database-1"
  allocated_storage       = 20
  db_name                 = "database1"
  engine                  = "postgres"
  engine_version          = "17.4"
  instance_class          = "db.t3.micro"
  username                = "postgres"
  password                = var.db_password
  storage_type            = "gp3"
  storage_encrypted       = true
  publicly_accessible     = false
  skip_final_snapshot     = true
  multi_az                = false
  backup_retention_period = 0

  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}