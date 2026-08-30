variable "aws_region" { default = "us-east-1" }
variable "project" { default = "8byte-assignment" }
variable "environment" { default = "staging" }
variable "image_tag" { default = "latest" }
variable "db_name" { default = "appdb" }
variable "db_username" { default = "appuser" }
variable "github_repository" { default = "" }
variable "enable_github_actions" { default = false }
