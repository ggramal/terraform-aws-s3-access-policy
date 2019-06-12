variable "ro_iam_policies" {
  type = object({
    s3_bucket_name    = string
    s3_bucket_folders = list(string)
    user_names        = list(string)
  })
  default = null
}

variable "rw_iam_policies" {
  type = object({
    s3_bucket_name    = string
    s3_bucket_folders = list(string)
    user_names        = list(string)
  })
  default = null
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
