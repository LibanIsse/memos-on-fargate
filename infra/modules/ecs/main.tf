# Create cloudwatch log
resource "aws_cloudwatch_log_group" "memos" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
}

# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "memos-cluster"
}

# Create ECS Task Defintion
resource "aws_ecs_task_definition" "memos" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = var.execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }


  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
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
          value = var.memos_dsn
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

# ECS service

resource "aws_ecs_service" "memos" {
  name            = "memos-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.memos.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_1_id, var.private_subnet_2_id]
    security_groups  = [var.task_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition]
  }



  depends_on = [aws_ecs_task_definition.memos]
}
