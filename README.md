# AWS DevOps technical assignment

A small Node.js API deployed on Amazon ECS Fargate, with PostgreSQL on RDS. Terraform provisions the complete environment; GitHub Actions tests, builds, publishes, and deploys the container.

## Architecture

`Internet -> ALB (public subnets) -> ECS Fargate (private subnets) -> RDS PostgreSQL (private subnets)`

The ALB is the only public entry point. The ECS security group accepts port 3000 only from the ALB; RDS accepts PostgreSQL only from ECS. Application logs go to CloudWatch Logs and the database connection string is held in Secrets Manager.

## Prerequisites

AWS CLI authenticated to the target account, Terraform >= 1.6, Docker, Node 22, and a GitHub repository. This configuration uses `us-east-1`. Do not commit credentials or `.tfvars` files.

## Deploy

1. Copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and set the repository name.
2. From `infra`, run `terraform init` and `terraform apply -target=aws_ecr_repository.app`. This creates the repository needed for the initial image.
3. Obtain the repository URL from `terraform output -raw ecr_repository_url`, authenticate Docker with ECR, then build and push the app with tag `initial`.
4. Run `terraform apply`. Open `application_url` and append `/health`.
5. Set the `AWS_DEPLOY_ROLE_ARN` GitHub Actions secret to `github_actions_role_arn`. Push to `main` to run tests, build the image, and deploy it.

For a cost-sensitive assignment account, destroy the environment when the demo is complete: `terraform destroy`. NAT Gateway and RDS incur charges while running.

## CI/CD

The workflow runs on `main` and manual dispatch. It runs the Node test suite, builds and scans via ECR on push, assumes an AWS role through GitHub OIDC, publishes an immutable commit-SHA image, then registers and deploys a revised ECS task definition. Configure the GitHub `production` environment with required reviewers for a manual production gate.

## Observability

CloudWatch Logs centralizes container stdout/stderr at `/ecs/<project>-<environment>`. `platform` dashboard shows ALB request count, 5xx count, response time, and ECS CPU/memory. `database` dashboard shows RDS CPU, connections, and free storage. The ALB 5xx alarm fires after more than five ELB 5xx responses in five minutes.

## Security decisions

- Private ECS and database subnets; no public RDS access.
- Layered security groups with only necessary ingress.
- Encryption at rest for RDS; database URL stored in Secrets Manager.
- GitHub OIDC removes long-lived AWS credentials from GitHub.
- ECR image scanning is enabled; deploy role has narrowly scoped ECR/ECS permissions.

## Trade-offs

One NAT gateway and a single-AZ RDS instance reduce cost for an assessment environment. The Free Tier account uses one day of automated RDS backup retention; a production design would use longer retention, NAT gateways per AZ, multi-AZ RDS, remote encrypted Terraform state with locking, WAF, HTTPS/ACM, alarms routed through SNS, and a database migration step.
