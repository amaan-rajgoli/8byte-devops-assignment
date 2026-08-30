resource "aws_iam_openid_connect_provider" "github" {
  count           = var.enable_github_actions ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_deploy" {
  count = var.enable_github_actions ? 1 : 0
  name  = "${local.name}-github-deploy"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{
    Effect    = "Allow"
    Principal = { Federated = aws_iam_openid_connect_provider.github[0].arn }
    Action    = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
      StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*" }
    }
  }] })
}

resource "aws_iam_role_policy" "github_deploy" {
  count = var.enable_github_actions ? 1 : 0
  name  = "deploy-ecs"
  role  = aws_iam_role.github_deploy[0].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
    { Effect = "Allow", Action = ["ecr:BatchCheckLayerAvailability", "ecr:CompleteLayerUpload", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart"], Resource = aws_ecr_repository.app.arn },
    { Effect = "Allow", Action = ["ecs:DescribeTaskDefinition", "ecs:RegisterTaskDefinition"], Resource = "*" },
    { Effect = "Allow", Action = ["ecs:UpdateService", "ecs:DescribeServices"], Resource = aws_ecs_service.app.id },
    { Effect = "Allow", Action = ["iam:PassRole"], Resource = aws_iam_role.execution.arn }
  ] })
}
