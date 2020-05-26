resource "aws_lb" "main" {
  name = "${var.project_name}-lb"
  load_balancer_type = "application"
  security_groups = [
    var.public_security_group_id]
  subnets = var.public_subnet_ids

  tags = {
    project = var.project_name
  }
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type = "forward"
  }
}

resource "aws_lb_target_group" "main" {
  name = "${var.project_name}-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200,301"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_autoscaling_group" "main" {
  name = "${var.project_name}-asg"
  launch_configuration = aws_launch_configuration.main.id

  vpc_zone_identifier = var.public_subnet_ids

  max_size = 1
  min_size = 1
  desired_capacity = 1

  health_check_type = "ELB"

  tag {
    key = "project"
    value = var.project_name
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "main" {
  name = "${var.project_name}-launch-configuration"
  image_id = "ami-088bb4cd2f62fc0e1" # Amazon ECS-optimized Amazon Linux 2 AMI
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance.id

  security_groups = [var.public_security_group_id]
  associate_public_ip_address = "true"
  key_name = var.ecs_key_pair_name
  user_data = <<EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_ecs_service" "service" {
  name = "${var.service_name}-ecs-service"
  task_definition = aws_ecs_task_definition.task.arn
  cluster = aws_ecs_cluster.cluster.id
  desired_count = var.desired_service_count
  iam_role = aws_iam_role.ecs_service.name
  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_port = 80
    container_name = var.container_name
  }

  depends_on = [
    aws_lb.main
  ]
}

resource "aws_ecs_task_definition" "task" {
  family = var.family
  container_definitions = var.container_definitions
  task_role_arn = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  dynamic "volume" {
    for_each = var.volume_name

    content {
      name = volume.value

      docker_volume_configuration {
        scope = "shared"
        autoprovision = true
        driver = "local"
      }
    }
  }
}

data "aws_iam_policy_document" "ecs_service" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service" {
  name = "ecs-service-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_service.json
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance" {
  name                = "ecs-instance-role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ecs_instance.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs_instance.id

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name                = "ecs-task-role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task.json
}

resource "aws_iam_role_policy" "s3_static_readwrite" {
  name = "ecs-task-static"
  policy = var.ecs-task-s3-static-policy
  role = aws_iam_role.ecs_task.id
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name                = "ecs-task-execution-role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "s3_env_read" {
  name = "ecs-task-env"
  policy = var.ecs-task-execution-s3-env-policy
  role = aws_iam_role.ecs_task_execution.id
}
