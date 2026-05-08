# Create cloudwatch log
resource "aws_cloudwatch_log_group" "memos" {
  name              = "/ecs/memos-logs"
  retention_in_days = 7
}

# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "memos-cluster"
}

# Create ECS Task Defintion
resource "aws_ecs_task_definition" "memos" {
  family                   = "memos-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }


  container_definitions = jsonencode([
    {
      name      = "memos"
      image     = "527814729206.dkr.ecr.eu-west-2.amazonaws.com/ecsmemos:d9d95fef5eed1b4db0bdf7ebb08a1b47a0daf27f"
      essential = true

      portMappings = [
        {
          containerPort = 5230
          hostPort      = 5230
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MEMOS_DRIVER"
          value = "postgres"
        },
        {
          name  = "MEMOS_DSN"
          value = local.memos_dsn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.memos.name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

locals {
  memos_dsn = "postgresql://postgres:${var.db_password}@${var.rds_endpoint}:5432/database1?sslmode=require"
}

# ECS service

resource "aws_ecs_service" "memos" {
  name            = "memos-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.memos.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_1_id, var.private_subnet_2_id]
    security_groups  = [var.task_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "memos"
    container_port   = 5230
  }

  #lifecycle {
  # ignore_changes = [task_definition]
  #}



  depends_on = [aws_ecs_task_definition.memos]
}
