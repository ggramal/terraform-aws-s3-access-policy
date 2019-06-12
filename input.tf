variable "s3_bucket_name" {
  type = "string"
}

variable "s3_bucket_arn" {
  type = "string"
}

variable "s3_bucket_ro_folders" {
  type        = "list"
  default     = []
  description = "folders to give read only access"
}

variable "user_names" {
  type        = "list"
  description = "List of users to whom aws iam user policy is assigned"
  default     = []
}

variable "user_arns" {
  type        = "list"
  description = "Principal to whom s3 bucket policy is assigned"
  default     = []
}

variable "s3_bucket_rw_folders" {
  type        = "list"
  default     = []
  description = "folders to give read write access"
}

variable "policy_name" {
  type        = "string"
  default     = ""
  description = "Name of the created  policy. If not specified. var.s3_bucket_name + '_(ro|rw)_acess_policy' string  will be used"
}

variable "cloudtrail_enabled" {
  default     = false
  description = "Disable or enable cloudtrail IAM policy on specified bucket"
}
