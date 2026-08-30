output "application_url" { value = "http://${aws_lb.main.dns_name}" }
output "ecr_repository_url" { value = aws_ecr_repository.app.repository_url }
output "github_actions_role_arn" { value = var.enable_github_actions ? aws_iam_role.github_deploy[0].arn : null }
output "platform_dashboard" { value = aws_cloudwatch_dashboard.platform.dashboard_name }
output "database_dashboard" { value = aws_cloudwatch_dashboard.database.dashboard_name }
