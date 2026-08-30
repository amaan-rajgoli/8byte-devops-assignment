# Challenges and resolutions

## Bootstrapping the first ECS image

ECS needs an image in ECR before the service can start, while the ECR repository is Terraform-managed. The deployment is split into a targeted ECR repository apply, an initial image push, and the complete Terraform apply. Subsequent changes are handled by GitHub Actions.

## Private workload connectivity

Fargate tasks run in private subnets, so they need outbound access to pull images and send logs. A NAT gateway provides this without making tasks publicly reachable.

## CI credentials

Rather than storing AWS access keys in GitHub, the workflow requests a short-lived OpenID Connect token and assumes a tightly scoped IAM role.

## Cost versus availability

The design uses one NAT gateway and single-AZ RDS to keep a short-lived environment affordable. The README identifies the high-availability upgrades appropriate for production.
