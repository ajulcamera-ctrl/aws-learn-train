variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "enable_dynamodb" {
  type    = bool
  default = true
}

variable "enable_rds" {
  type    = bool
  default = true
}

variable "enable_redis" {
  type    = bool
  default = true
}

variable "enable_s3" {
  type    = bool
  default = true
}

variable "enable_waf" {
  type    = bool
  default = true
}
