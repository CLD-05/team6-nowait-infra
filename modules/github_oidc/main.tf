# ========================================
# GitHub OIDC Provider
# ========================================

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-github-oidc-provider"
  })
}


# ========================================
# Assume Role Policy
# ========================================

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
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

      values = [
        for branch in var.allowed_branches :
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${branch}"
      ]
    }
  }
}


# ========================================
# GitHub Actions Role
# ========================================

resource "aws_iam_role" "github_actions" {
  name                 = "${var.name_prefix}-github-actions-role"
  assume_role_policy   = data.aws_iam_policy_document.github_assume_role.json
  permissions_boundary = var.iam_role_permissions_boundary

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-github-actions-role"
  })
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

resource "aws_iam_policy" "ecr_push" {
  name   = "${var.name_prefix}-github-actions-ecr-push-policy"
  policy = data.aws_iam_policy_document.ecr_push.json

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-github-actions-ecr-push-policy"
  })
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_push.arn
}