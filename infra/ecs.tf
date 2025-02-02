resource "aws_ecs_cluster" "cluster" {
  name = "hackathon-fiap-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "hackathon-fiap-processamento"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::369780787289:role/LabRole"

  container_definitions = jsonencode([
    {
      name      = "app-container"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "hacksthon-fiap-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-06e3bb63a3ecd19db", "subnet-0c60c32538ce92175", "subnet-0f4f3b651df6150b0"]
    security_groups  = ["sg-0708538b995a2467c"]
    assign_public_ip = true
  }
  desired_count = 0
}