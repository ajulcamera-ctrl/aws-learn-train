# day23 main.tf
terraform {
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region
}

# Modules placeholders
# Feature flags determine which modules are active
