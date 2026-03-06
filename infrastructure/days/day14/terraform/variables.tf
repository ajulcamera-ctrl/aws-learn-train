variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "enable_rds" {
  type    = bool
  default = false
}

variable "enable_redis" {
  type    = bool
  default = false
}

variable "enable_s3" {
  type    = bool
  default = false
}

variable "enable_waf" {
  type    = bool
  default = false
}
