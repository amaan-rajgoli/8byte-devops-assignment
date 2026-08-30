resource "aws_cloudwatch_dashboard" "platform" {
  dashboard_name = "${local.name}-platform"
  dashboard_body = jsonencode({ widgets = [
    { type = "metric", width = 12, height = 6, properties = { title = "ALB traffic and errors", region = var.aws_region, metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum" }], [".", "HTTPCode_ELB_5XX_Count", ".", ".", { stat = "Sum" }], [".", "TargetResponseTime", ".", ".", { stat = "Average" }]] } },
    { type = "metric", width = 12, height = 6, properties = { title = "ECS service utilization", region = var.aws_region, metrics = [["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name], [".", "MemoryUtilization", ".", ".", ".", "."]] } }
  ] })
}
resource "aws_cloudwatch_dashboard" "database" {
  dashboard_name = "${local.name}-database"
  dashboard_body = jsonencode({ widgets = [{ type = "metric", width = 24, height = 6, properties = { title = "RDS health", region = var.aws_region, metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.main.id], [".", "DatabaseConnections", ".", "."], [".", "FreeStorageSpace", ".", "."]] } }] })
}
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  dimensions          = { LoadBalancer = aws_lb.main.arn_suffix }
}
