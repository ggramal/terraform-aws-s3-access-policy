/* Module for rendering aws policy json for accessing s3 bucket objects */

/* Debug */

resource "null_resource" "debug" {
  count = 0

  triggers = {
    dbg = data.aws_iam_policy_document.s3_iam_rw_policy_document[count.index].json
  }
}

data "aws_iam_policy_document" "s3_iam_ro_policy_document" {
  count = var.ro_iam_policies != null ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["s3:Get*", "s3:List*"]
    resources = compact(concat(
      [
        for folder in var.ro_iam_policies.s3_bucket_folders :
        "arn:aws:s3:::${var.ro_iam_policies.s3_bucket_name}/${folder}"
      ],
      [
        for folder in var.ro_iam_policies.s3_bucket_folders :
        "arn:aws:s3:::${var.ro_iam_policies.s3_bucket_name}"
        if folder == "*"
      ],
    ))

  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = var.ro_iam_policies.s3_bucket_folders
    }

    resources = ["arn:aws:s3:::${var.ro_iam_policies.s3_bucket_name}"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
    ]

    resources = ["arn:aws:s3:::*"]
  }
}

data "aws_iam_policy_document" "s3_iam_rw_policy_document" {
  count = var.rw_iam_policies != null ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = compact(concat(
      [
        for folder in var.rw_iam_policies.s3_bucket_folders :
        "arn:aws:s3:::${var.rw_iam_policies.s3_bucket_name}/${folder}"
      ],
      [
        for folder in var.rw_iam_policies.s3_bucket_folders :
        "arn:aws:s3:::${var.rw_iam_policies.s3_bucket_name}"
        if folder == "*"
      ],
    ))

  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = var.rw_iam_policies.s3_bucket_folders
    }

    resources = ["arn:aws:s3:::${var.rw_iam_policies.s3_bucket_name}"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
    ]

    resources = ["arn:aws:s3:::*"]
  }
}



#data "template_file" "cloudtrail_iam_statement" {
#  count = var.cloudtrail_enabled
#
#  # Note the comma ',' at the beginning of the template
#  # Dont remove it, its needed :P
#  template = <<EOF
#,
#	{
#            "Sid": "AWSCloudTrailAclCheck",
#            "Effect": "Allow",
#            "Principal": {
#                "Service": "cloudtrail.amazonaws.com"
#            },
#            "Action": "s3:GetBucketAcl",
#            "Resource": "$${s3_bucket_arn}"
#        },
#        {
#            "Sid": "AWSCloudTrailWrite",
#            "Effect": "Allow",
#            "Principal": {
#                "Service": "cloudtrail.amazonaws.com"
#            },
#            "Action": "s3:PutObject",
#            "Resource": "$${s3_bucket_arn}/*",
#            "Condition": {
#                "StringEquals": {
#                    "s3:x-amz-acl": "bucket-owner-full-control"
#                }
#            }
#        }
#EOF
#
#  vars = {
#    s3_bucket_arn = var.s3_bucket_arn
#  }
#}
#
#data "template_file" "s3_bucket_ro_policy" {
#  count = length(var.s3_bucket_ro_folders) > 0 && length(var.user_arns) > 0 ? 1 : 0
#
#  template = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "",
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": $${user_arns}
#            },
#            "Action": ["s3:List*","s3:Get*"],
#            "Resource": $${s3_bucket_ro_arns}
#        },
#        {
#            "Sid": "",
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": $${user_arns}
#            },
#            "Action": "s3:ListBucket",
#            "Resource": $${s3_bucket_arn},
#            "Condition": {
#                "StringLike": {
#                    "s3:prefix":$${s3_bucket_ro_folders}
#                }
#            }
#        }$${cloudtrail_iam_statement}
#    ]
#}
#EOF
#
#  vars = {
#    user_arns                = jsonencode(var.user_arns)
#    s3_bucket_arn            = jsonencode(var.s3_bucket_arn)
#    s3_bucket_ro_folders     = jsonencode(var.s3_bucket_ro_folders)
#    s3_bucket_ro_arns        = jsonencode(compact(concat(formatlist("%s/%s",var.s3_bucket_arn,var.s3_bucket_ro_folders), split(" ",join("",var.s3_bucket_ro_folders) == "*" ? var.s3_bucket_arn : ""))))
#    cloudtrail_iam_statement = var.cloudtrail_enabled ? element(concat(list(""),data.template_file.cloudtrail_iam_statement.*.rendered),1) : ""
#  }
#}
#
#data "template_file" "s3_bucket_rw_policy" {
#  count = length(var.s3_bucket_rw_folders) > 0 && length(var.user_arns) > 0 ? 1 : 0
#
#  template = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "",
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": $${user_arns}
#            },
#            "Action": ["s3:*"],
#            "Resource": $${s3_bucket_rw_arns}
#        },
#        {
#            "Sid": "",
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": $${user_arns}
#            },
#            "Action": "s3:ListBucket",
#            "Resource": $${s3_bucket_arn},
#            "Condition": {
#                "StringLike": {
#                    "s3:prefix":$${s3_bucket_rw_folders}
#                }
#            }
#        }$${cloudtrail_iam_statement}
#    ]
#}
#EOF
#
#  vars = {
#    user_arns                = jsonencode(var.user_arns)
#    s3_bucket_arn            = jsonencode(var.s3_bucket_arn)
#    s3_bucket_rw_folders     = jsonencode(var.s3_bucket_rw_folders)
#    s3_bucket_rw_arns        = jsonencode(compact(concat(formatlist("%s/%s",var.s3_bucket_arn,var.s3_bucket_rw_folders), split(" ",join("",var.s3_bucket_rw_folders) == "*" ? var.s3_bucket_arn : ""))))
#    cloudtrail_iam_statement = var.cloudtrail_enabled ? element(concat(list(""),data.template_file.cloudtrail_iam_statement.*.rendered),1) : ""
#  }
#}
#
resource "aws_iam_user_policy_attachment" "s3_ro_policy_attachment" {
  count      = var.ro_iam_policies != null ? length(var.ro_iam_policies.user_names) : 0
  user       = var.ro_iam_policies.user_names[count.index]
  policy_arn = aws_iam_policy.s3_ro_policy[0].arn
}

resource "aws_iam_user_policy_attachment" "s3_rw_policy_attachment" {
  count      = var.rw_iam_policies != null ? length(var.rw_iam_policies.user_names) : 0
  user       = var.rw_iam_policies.user_names[count.index]
  policy_arn = aws_iam_policy.s3_rw_policy[0].arn
}

resource "aws_iam_policy" "s3_ro_policy" {
  count  = var.ro_iam_policies != null ? 1 : 0
  name   = var.policy_name == "" ? format("%s_ro_access_policy", var.ro_iam_policies.s3_bucket_name) : var.policy_name
  policy = data.aws_iam_policy_document.s3_iam_ro_policy_document[0].json
}

resource "aws_iam_policy" "s3_rw_policy" {
  count  = var.rw_iam_policies != null ? 1 : 0
  name   = var.policy_name == "" ? format("%s_rw_access_policy", var.rw_iam_policies.s3_bucket_name) : var.policy_name
  policy = data.aws_iam_policy_document.s3_iam_rw_policy_document[0].json
}

#resource "aws_s3_bucket_policy" "s3_ro_bucket_policy" {
#  count  = length(var.s3_bucket_ro_folders) > 0 && length(var.user_arns) > 0 ? 1 : 0
#  bucket = var.s3_bucket_name
#  policy = data.template_file.s3_bucket_ro_policy.rendered
#}
#
#resource "aws_s3_bucket_policy" "s3_rw_bucket_policy" {
#  count  = length(var.s3_bucket_rw_folders) > 0 && length(var.user_arns) > 0 ? 1 : 0
#  bucket = var.s3_bucket_name
#  policy = data.template_file.s3_bucket_rw_policy.rendered
#}
