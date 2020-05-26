resource "aws_db_subnet_group" "private" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "db" {
  identifier_prefix = var.project_name
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.private.id
  vpc_security_group_ids = [var.private_sg_id]

  skip_final_snapshot = var.skip_final_snapshot

  tags = {
    project = var.project_name
  }
}

resource "aws_ssm_parameter" "name" {
  description = "${var.project_name} db name"
  name = "/db/mysql/${var.project_name}/name"
  type = "SecureString"
  value = var.db_name
}

resource "aws_ssm_parameter" "host" {
  description = "Host endpoint to connect to the ${var.project_name} db"
  name = "/db/mysql/${var.project_name}/host"
  type = "SecureString"
  value = aws_db_instance.db.address
}

resource "aws_ssm_parameter" "port" {
  description = "Port to connect to the ${var.project_name} db"
  name = "/db/mysql/${var.project_name}/port"
  type = "SecureString"
  value = aws_db_instance.db.port
}

resource "aws_ssm_parameter" "username" {
  description = "${var.project_name} db username"
  name = "/db/mysql/${var.project_name}/username"
  type = "SecureString"
  value = var.db_username
}

resource "aws_ssm_parameter" "password" {
  description = "${var.project_name} db password"
  name = "/db/mysql/${var.project_name}/password"
  type = "SecureString"
  value = var.db_password
}

