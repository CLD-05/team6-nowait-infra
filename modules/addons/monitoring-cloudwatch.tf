# -------------------------------------------------------------------
# Grafana CloudWatch 데이터소스용 IAM
#
# RDS/ElastiCache는 AWS 관리형 서비스라 Prometheus가 직접 스크랩할 수 없고
# CloudWatch 메트릭으로만 존재한다. Grafana 파드(kube-prometheus-stack-grafana
# 서비스어카운트)에 Pod Identity로 읽기 전용 CloudWatch 권한을 붙여서
# CloudWatch 데이터소스가 동작하게 한다.
# -------------------------------------------------------------------
resource "aws_iam_role" "grafana_cloudwatch" {
  count = var.enable_kube_prometheus_stack ? 1 : 0

  name                 = "${var.name_prefix}-grafana-cloudwatch-role"
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
    Name = "${var.name_prefix}-grafana-cloudwatch-role"
    Team = var.team
  }
}

resource "aws_iam_policy" "grafana_cloudwatch" {
  count = var.enable_kube_prometheus_stack ? 1 : 0

  name = "${var.name_prefix}-grafana-cloudwatch-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchRead"
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetInsightRuleReport"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowResourceTagRead"
        Effect = "Allow"
        Action = [
          "tag:GetResources"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEC2RegionRead"
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-grafana-cloudwatch-read-policy"
    Team = var.team
  }
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch" {
  count = var.enable_kube_prometheus_stack ? 1 : 0

  role       = aws_iam_role.grafana_cloudwatch[0].name
  policy_arn = aws_iam_policy.grafana_cloudwatch[0].arn
}

resource "aws_eks_pod_identity_association" "grafana_cloudwatch" {
  count = var.enable_kube_prometheus_stack ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = "monitoring"
  service_account = "kube-prometheus-stack-grafana"
  role_arn        = aws_iam_role.grafana_cloudwatch[0].arn

  depends_on = [
    aws_iam_role_policy_attachment.grafana_cloudwatch,
    helm_release.kube_prometheus_stack
  ]
}
