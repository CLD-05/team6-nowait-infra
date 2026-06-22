# ========================================
# OIDC Subject
# ========================================
#
# GitHub Actions에서 environment를 사용하면 OIDC sub claim이
# 브랜치 기준이 아니라 environment 기준으로 바뀝니다.
#
# 예:
# - environment 미사용:
#   repo:CLD-05/team6-nowait-app:ref:refs/heads/develop
#
# - environment 사용:
#   repo:CLD-05/team6-nowait-app:environment:development
#
# 따라서 github_environment 값이 있으면 environment 기준 subject를 사용하고,
# 없으면 기존처럼 allowed_branches 기준 subject를 사용합니다.
# ========================================
locals {
  oidc_subjects = var.github_environment != null && var.github_environment != "" ? [
    "repo:${var.github_org}/${var.github_repo}:environment:${var.github_environment}"
  ] : [
    for branch in var.allowed_branches :
    "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${branch}"
  ]
}


# ========================================
# Assume Role Policy
# ========================================
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        var.github_oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = local.oidc_subjects
    }
  }
}


# ========================================
# GitHub Actions Role
# ========================================
resource "aws_iam_role" "this" {
  name                 = "${var.name_prefix}-${var.role_name_suffix}-github-actions-role"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  permissions_boundary = var.iam_role_permissions_boundary

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-${var.role_name_suffix}-github-actions-role"
    DeployRole = var.role_name_suffix
  })
}


# ========================================
# ECR Read Policy
# ========================================
data "aws_iam_policy_document" "ecr_read" {
  statement {
    sid    = "AllowECRLogin"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRRead"
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]

    resources = [
      var.ecr_repository_arn
    ]
  }
}


# ========================================
# ECR Push Policy
# ========================================
data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid    = "AllowECRLogin"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRPush"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      var.ecr_repository_arn
    ]
  }
}


# ========================================
# ECR Policy
# ========================================
resource "aws_iam_policy" "ecr" {
  name = "${var.name_prefix}-${var.role_name_suffix}-github-actions-ecr-${var.ecr_access}-policy"

  policy = (
    var.ecr_access == "push"
    ? data.aws_iam_policy_document.ecr_push.json
    : data.aws_iam_policy_document.ecr_read.json
  )

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-${var.role_name_suffix}-github-actions-ecr-${var.ecr_access}-policy"
    DeployRole = var.role_name_suffix
  })
}


# ========================================
# Attach ECR Policy to Role
# ========================================
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecr.arn
}