data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------
# 1. 일반 EKS Managed Add-ons 설치
# -------------------------------------------------------------------
#
# 이 리소스는 EKS 기본 Add-ons를 설치합니다.
#
# 단, aws-ebs-csi-driver는 여기서 제외합니다.
# 이유:
# - aws-ebs-csi-driver는 AWS EBS 권한이 필요합니다.
# - 권한 연결 없이 먼저 생성되면 ebs-csi-controller Pod가
#   CrashLoopBackOff 상태가 될 수 있습니다.
# - 그래서 아래에서 별도 aws_eks_addon 리소스로 분리하고,
#   pod_identity_association을 add-on 생성 시점에 함께 설정합니다.
#
# 여기서 설치되는 일반 Add-ons:
# - vpc-cni
# - coredns
# - kube-proxy
# - eks-pod-identity-agent
# -------------------------------------------------------------------
resource "aws_eks_addon" "this" {
  for_each = local.general_eks_addon_set

  # Add-on을 설치할 대상 EKS Cluster 이름입니다.
  cluster_name = var.cluster_name

  # 설치할 Add-on 이름입니다.
  # 예: vpc-cni, coredns, kube-proxy, eks-pod-identity-agent
  addon_name = each.value

  # Add-on 버전입니다.
  #
  # var.addon_versions에 값이 있으면 해당 버전으로 고정합니다.
  # 값이 없으면 null이 들어가며, AWS/EKS가 클러스터 버전에 맞는
  # 기본 호환 버전을 선택합니다.
  addon_version = lookup(var.addon_versions, each.value, null)

  # 생성 시 충돌이 나면 Terraform 설정 기준으로 덮어씁니다.
  #
  # 처음 생성할 때는 Terraform이 기준이 되는 것이 안전합니다.
  resolve_conflicts_on_create = "OVERWRITE"

  # 업데이트 시에는 기존 설정을 최대한 보존합니다.
  #
  # 운영 중 수동 변경 사항이 있을 수 있으므로 update에서는 PRESERVE를 사용합니다.
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name = "${var.cluster_name}-${each.value}"
  }
}

# -------------------------------------------------------------------
# 2. EBS CSI Driver용 Pod Identity IAM Role 생성
# -------------------------------------------------------------------
#
# aws-ebs-csi-driver는 Kubernetes PVC 요청을 실제 AWS EBS Volume으로
# 생성/삭제/연결하는 역할을 합니다.
#
# 예:
# - Grafana PVC
# - Prometheus PVC
# - 애플리케이션 PVC
#
# 이 작업을 하려면 AWS EBS API를 호출할 권한이 필요합니다.
# 따라서 EBS CSI Driver Pod가 사용할 IAM Role을 생성합니다.
#
# count 조건:
# - var.eks_addons 안에 "aws-ebs-csi-driver"가 포함되어 있고
# - enable_ebs_csi_pod_identity가 true일 때만 생성합니다.
#
# 개인 계정 테스트:
# - iam_role_permissions_boundary = "arn:aws:iam::aws:policy/AdministratorAccess"
#
# 학원 계정:
# - iam_role_permissions_boundary = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
# -------------------------------------------------------------------
resource "aws_iam_role" "ebs_csi" {
  count = local.enable_ebs_csi_driver && var.enable_ebs_csi_pod_identity ? 1 : 0

  name = "${var.name_prefix}-ebs-csi-role"

  # IAM Role의 최대 권한 범위를 제한하는 permissions boundary입니다.
  #
  # 학원 계정에서는 TeamRuntimeBoundary가 필수입니다.
  # 개인 계정 테스트에서는 유효한 boundary ARN을 넣어야 합니다.
  permissions_boundary = var.iam_role_permissions_boundary

  # EKS Pod Identity용 trust policy입니다.
  #
  # 일반 EC2 Role이면 Principal이 ec2.amazonaws.com이지만,
  # Pod Identity Role은 pods.eks.amazonaws.com을 사용합니다.
  #
  # 즉, 이 Role은 EKS Pod Identity가 Assume할 수 있는 Role입니다.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-ebs-csi-role"
  }
}

# -------------------------------------------------------------------
# 3. EBS CSI Driver IAM Role에 EBS 관리 정책 연결
# -------------------------------------------------------------------
#
# IAM Role만 만들면 아직 아무 권한이 없습니다.
#
# AmazonEBSCSIDriverPolicy를 연결해야 EBS CSI Driver가
# EBS Volume을 생성/삭제/Attach/Detach 할 수 있습니다.
#
# 이 정책은 AWS 관리형 정책입니다.
# -------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count = local.enable_ebs_csi_driver && var.enable_ebs_csi_pod_identity ? 1 : 0

  role = aws_iam_role.ebs_csi[0].name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# -------------------------------------------------------------------
# 4. EBS CSI Driver Add-on 별도 설치
# -------------------------------------------------------------------
#
# aws-ebs-csi-driver는 일반 Add-on 반복 생성 대상에서 제외하고
# 별도 리소스로 생성합니다.
#
# 이유:
# - EBS CSI Driver는 AWS EBS 권한이 필요합니다.
# - 기존처럼 add-on을 먼저 만들고, Pod Identity Association을 나중에 만들면
#   ebs-csi-controller Pod가 권한 없이 먼저 떠서 CrashLoopBackOff가 날 수 있습니다.
#
# 개선 방식:
# - aws_eks_addon 리소스 내부의 pod_identity_association 블록을 사용합니다.
# - add-on 생성 시점에 ebs-csi-controller-sa ServiceAccount와 IAM Role 연결 정보를
#   함께 전달합니다.
#
# 연결 구조:
#
# kube-system/ebs-csi-controller-sa
#   ↓
# Pod Identity Association
#   ↓
# team6-nowait-dev-ebs-csi-role
#   ↓
# AmazonEBSCSIDriverPolicy
#   ↓
# AWS EBS Volume 생성/삭제/연결 가능
# -------------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi" {
  count = local.enable_ebs_csi_driver ? 1 : 0

  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  # EBS CSI Driver Add-on 버전입니다.
  #
  # addon_versions에 "aws-ebs-csi-driver" 값이 있으면 해당 버전 사용.
  # 없으면 AWS/EKS 기본 호환 버전을 사용합니다.
  addon_version = lookup(var.addon_versions, "aws-ebs-csi-driver", null)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  # EBS CSI Driver에 Pod Identity 연결 정보를 함께 전달합니다.
  #
  # enable_ebs_csi_pod_identity = true일 때만 생성됩니다.
  #
  # service_account:
  # - EBS CSI Driver Controller가 사용하는 ServiceAccount 이름입니다.
  #
  # role_arn:
  # - 위에서 만든 EBS CSI Driver용 IAM Role ARN입니다.
  dynamic "pod_identity_association" {
    for_each = var.enable_ebs_csi_pod_identity ? [1] : []

    content {
      service_account = local.ebs_csi_service_account
      role_arn        = aws_iam_role.ebs_csi[0].arn
    }
  }

  # 의존성:
  #
  # 1. 일반 Add-ons가 먼저 설치되어야 합니다.
  #    특히 eks-pod-identity-agent가 먼저 있어야 Pod Identity를 사용할 수 있습니다.
  #
  # 2. EBS CSI IAM Role에 AmazonEBSCSIDriverPolicy가 먼저 연결되어야 합니다.
  #
  # 그 다음 aws-ebs-csi-driver Add-on을 생성합니다.
  depends_on = [
    aws_eks_addon.this,
    aws_iam_role_policy_attachment.ebs_csi
  ]

  tags = {
    Name = "${var.cluster_name}-aws-ebs-csi-driver"
  }
}

# -------------------------------------------------------------------
# 5. AWS Load Balancer Controller IAM Role (Pod Identity)
# -------------------------------------------------------------------
#
# LBC는 ALB/NLB를 생성/삭제/관리합니다.
# 이를 위해 AWS ELB API 호출 권한이 필요합니다.
#
# 연결 구조:
#
# kube-system/aws-load-balancer-controller (ServiceAccount)
#   ↓
# Pod Identity Association
#   ↓
# team6-nowait-dev-lbc-role
#   ↓
# team6-nowait-dev-lbc-policy
# -------------------------------------------------------------------
resource "aws_iam_role" "lbc" {
  name                 = "${var.name_prefix}-lbc-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-lbc-role"
    Team = "team6"
  }
}


# -------------------------------------------------------------------
# AWS Load Balancer Controller IAM Policy
# -------------------------------------------------------------------
#
# AWS Load Balancer Controller가 ALB/NLB, Target Group, Listener,
# Security Group, Subnet/Tag 등을 관리할 수 있도록 전용 IAM Policy를 생성합니다.
# -------------------------------------------------------------------
resource "aws_iam_policy" "lbc" {
  name = "${var.name_prefix}-lbc-policy"

  policy = file("${path.module}/iam_policy_lbc.json")

  tags = {
    Name = "${var.name_prefix}-lbc-policy"
    Team = var.team
  }
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc.arn

  depends_on = [
    aws_eks_addon.this,
    aws_iam_role_policy_attachment.lbc
  ]
}


# -------------------------------------------------------------------
# AWS Load Balancer Controller Helm Release
# -------------------------------------------------------------------
resource "helm_release" "lbc" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.lbc_chart_version

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.lbc
  ]
}

# -------------------------------------------------------------------
# metrics-server Helm Release
# -------------------------------------------------------------------
resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.metrics_server_chart_version
  create_namespace = false

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls"
      ]
    })
  ]
}

# -------------------------------------------------------------------
# External Secrets Operator Helm Release
# -------------------------------------------------------------------
resource "helm_release" "eso" {
  name             = "external-secrets"
  namespace        = local.eso_namespace
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.eso_chart_version
  create_namespace = true

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = local.eso_service_account
      }
    })
  ]

  depends_on = [
    aws_eks_addon.this,
    aws_iam_role_policy_attachment.eso
  ]
}


# -------------------------------------------------------------------
# External Secrets Operator IAM Role (Pod Identity)
# -------------------------------------------------------------------
#
# External Secrets Operator가 AWS SSM Parameter Store를 읽기 위한 IAM Role입니다.
#
# 연결 구조:
#
# external-secrets/external-secrets ServiceAccount
#   ↓
# Pod Identity Association
#   ↓
# team6-nowait-dev-eso-role
#   ↓
# SSM Parameter Store read policy
# -------------------------------------------------------------------
resource "aws_iam_role" "eso" {
  count = var.enable_eso_pod_identity ? 1 : 0

  name                 = "${var.name_prefix}-eso-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eso-role"
    Team = var.team
  }
}

resource "aws_iam_policy" "eso" {
  count = var.enable_eso_pod_identity ? 1 : 0

  name = "${var.name_prefix}-eso-ssm-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadNowaitParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.secrets_parameter_prefix}/*"
        ]
      },
      {
        Sid    = "DescribeParameters"
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eso-ssm-read-policy"
    Team = var.team
  }
}

resource "aws_iam_role_policy_attachment" "eso" {
  count = var.enable_eso_pod_identity ? 1 : 0

  role       = aws_iam_role.eso[0].name
  policy_arn = aws_iam_policy.eso[0].arn
}


resource "aws_eks_pod_identity_association" "eso" {
  count = var.enable_eso_pod_identity ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = local.eso_namespace
  service_account = local.eso_service_account
  role_arn        = aws_iam_role.eso[0].arn

  depends_on = [
    helm_release.eso,
    aws_iam_role_policy_attachment.eso
  ]
}

# -------------------------------------------------------------------
# NoWait API IAM Role (Pod Identity)
# -------------------------------------------------------------------
#
# nowait-api Pod가 AWS 리소스에 접근하기 위한 IAM Role입니다.
#
# 현재 권한:
# - S3 Image Bucket Presigned URL 발급용 권한
#
# 연결 구조:
#
# nowait-dev/nowait-api ServiceAccount
#   ↓
# Pod Identity Association
#   ↓
# team6-nowait-dev-nowait-api-role
#   ↓
# S3 Image Bucket 접근 권한
# -------------------------------------------------------------------
resource "aws_iam_role" "nowait_api" {
  count = var.enable_nowait_api_pod_identity ? 1 : 0

  name                 = "${var.name_prefix}-nowait-api-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-nowait-api-role"
    Team = var.team
  }
}


# -------------------------------------------------------------------
# NoWait API S3 Image Bucket IAM Policy
# -------------------------------------------------------------------
#
# nowait-api가 Presigned URL을 발급하기 위해 필요한 S3 권한입니다.
#
# PutObject:
# - 브라우저가 presigned URL로 이미지 업로드
#
# GetObject:
# - 이미지 조회용 presigned URL 발급 시 사용
#
# DeleteObject:
# - 이미지 삭제 기능 구현 시 사용
#
# AbortMultipartUpload:
# - 멀티파트 업로드 중단 시 사용 가능
# -------------------------------------------------------------------
resource "aws_iam_policy" "nowait_api_s3" {
  count = var.enable_nowait_api_pod_identity && var.image_bucket_arn != null ? 1 : 0

  name = "${var.name_prefix}-nowait-api-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessImageBucketObjects"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "${var.image_bucket_arn}/*"
        ]
      },
      {
        Sid    = "ListImageBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          var.image_bucket_arn
        ]
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-nowait-api-s3-policy"
    Team = var.team
  }
}


# -------------------------------------------------------------------
# NoWait API IAM Role Policy Attachment
# -------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "nowait_api_s3" {
  count = var.enable_nowait_api_pod_identity && var.image_bucket_arn != null ? 1 : 0

  role       = aws_iam_role.nowait_api[0].name
  policy_arn = aws_iam_policy.nowait_api_s3[0].arn
}


# -------------------------------------------------------------------
# NoWait API Pod Identity Association
# -------------------------------------------------------------------
#
# nowait-api ServiceAccount에 IAM Role을 연결합니다.
#
# 주의:
# Kubernetes Deployment에서 반드시 아래처럼 설정해야 합니다.
#
# serviceAccountName: nowait-api
# -------------------------------------------------------------------
resource "aws_eks_pod_identity_association" "nowait_api" {
  count = var.enable_nowait_api_pod_identity ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.nowait_api_namespace
  service_account = var.nowait_api_service_account
  role_arn        = aws_iam_role.nowait_api[0].arn

  depends_on = [
    aws_eks_addon.this,
    aws_iam_role_policy_attachment.nowait_api_s3
  ]
}