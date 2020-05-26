resource "aws_cloudwatch_log_group" "main" {
  name = "${var.project_name}-logs"
  retention_in_days = var.retention_in_days

  tags = {
    project = var.project_name
  }
}

resource "aws_cloudwatch_log_stream" "stream" {
  log_group_name = aws_cloudwatch_log_group.main.name

  count = length(var.stream_names)
  name = var.stream_names[count.index]
}