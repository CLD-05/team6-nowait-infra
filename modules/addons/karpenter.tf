# -------------------------------------------------------------------
# Karpenter namespace
# -------------------------------------------------------------------
resource "kubernetes_namespace" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  metadata {
    name = local.karpenter_namespace
  }
}

# -------------------------------------------------------------------
# Karpenter controller IAM Role
# -------------------------------------------------------------------
resource "aws_iam_role" "karpenter_controller" {
  count = var.enable_karpenter ? 1 : 0

  name                 = "${var.name_prefix}-karpenter-controller-role"
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
    Name = "${var.name_prefix}-karpenter-controller-role"
    Team = var.team
  }
}

# -------------------------------------------------------------------
# Karpenter node IAM Role
# -------------------------------------------------------------------
resource "aws_iam_role" "karpenter_node" {
  count = var.enable_karpenter ? 1 : 0

  name                 = "${var.name_prefix}-karpenter-node-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-karpenter-node-role"
    Team = var.team
  }
}


# -------------------------------------------------------------------
# Karpenter node role policy attachments
# -------------------------------------------------------------------
locals {
  karpenter_node_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}



# -------------------------------------------------------------------
# Karpenter controller IAM Policy
# -------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "karpenter_node" {
  count = var.enable_karpenter ? length(local.karpenter_node_policy_arns) : 0

  role       = aws_iam_role.karpenter_node[0].name
  policy_arn = local.karpenter_node_policy_arns[count.index]
}

resource "aws_iam_policy" "karpenter_controller" {
  count = var.enable_karpenter ? 1 : 0

  name = "${var.name_prefix}-karpenter-controller-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2Actions"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEC2DescribeActions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSSMRead"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPricingRead"
        Effect = "Allow"
        Action = [
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEKSDescribeCluster"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPassNodeRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.karpenter_node[0].arn
      },
      {
        Sid    = "AllowInstanceProfileActions"
        Effect = "Allow"
        Action = [
          "iam:CreateInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-karpenter-controller-policy"
    Team = var.team
  }
}

# -------------------------------------------------------------------
# Karpenter Node Access Entry
# -------------------------------------------------------------------
resource "aws_eks_access_entry" "karpenter_node" {
  count = var.enable_karpenter ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node[0].arn
  type          = "EC2_LINUX"

  depends_on = [
    aws_iam_role_policy_attachment.karpenter_node
  ]
}

# -------------------------------------------------------------------
# Karpenter controller role attachment
# -------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  count = var.enable_karpenter ? 1 : 0

  role       = aws_iam_role.karpenter_controller[0].name
  policy_arn = aws_iam_policy.karpenter_controller[0].arn
}


# -------------------------------------------------------------------
# Karpenter Pod Identity Association
# -------------------------------------------------------------------
resource "aws_eks_pod_identity_association" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = local.karpenter_namespace
  service_account = local.karpenter_service_account
  role_arn        = aws_iam_role.karpenter_controller[0].arn

  depends_on = [
    kubernetes_namespace.karpenter,
    aws_iam_role_policy_attachment.karpenter_controller
  ]
}

# -------------------------------------------------------------------
# Karpenter Helm release
# -------------------------------------------------------------------
resource "helm_release" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  name      = "karpenter"
  namespace = kubernetes_namespace.karpenter[0].metadata[0].name

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_chart_version

  values = var.karpenter_values_file != null ? [
    file(var.karpenter_values_file)
  ] : []

  set = [
    {
      name  = "settings.clusterName"
      value = var.cluster_name
    }
  ]

  depends_on = [
    kubernetes_namespace.karpenter,
    aws_eks_pod_identity_association.karpenter
  ]
}

# -------------------------------------------------------------------
# Karpenter EC2NodeClass (default)
#
# subnet/SG는 모듈.network가 enable_karpenter_discovery_tags=true일 때 붙이는
# "karpenter.sh/discovery=<cluster_name>" 태그로 자동 탐색한다(이미 적용돼 있음).
# -------------------------------------------------------------------
resource "kubernetes_manifest" "karpenter_ec2nodeclass_default" {
  count = var.enable_karpenter ? 1 : 0

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      amiSelectorTerms = [
        { alias = "al2023@latest" }
      ]
      role = aws_iam_role.karpenter_node[0].name
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      tags = {
        Team                     = var.team
        "karpenter.sh/discovery" = var.cluster_name
      }
    }
  }

  depends_on = [
    helm_release.karpenter
  ]
}

# -------------------------------------------------------------------
# Karpenter NodePool (default)
#
# 부하테스트 기간 동안 prod 근접 사양(m6i.large)으로도 노드를 띄울 수 있도록
# t3.large/m6i.large만 허용한다. spot은 제외(on-demand만) — 테스트 중 변동성을
#배제하기 위함. 트래픽이 빠지면 consolidation으로 자동 회수한다.
# -------------------------------------------------------------------
resource "kubernetes_manifest" "karpenter_nodepool_default" {
  count = var.enable_karpenter ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      template = {
        spec = {
          requirements = [
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = ["t3.large", "m6i.large"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            }
          ]
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
        }
      }
      limits = {
        cpu    = "16"
        memory = "64Gi"
      }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "5m"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.karpenter_ec2nodeclass_default,
    helm_release.karpenter
  ]
}

