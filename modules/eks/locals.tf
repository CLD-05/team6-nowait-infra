locals {
  # EKS Cluster 이름입니다.
  # 예:
  # dev  = team6-nowait-dev-eks
  # prod = team6-nowait-prod-eks
  cluster_name = "${var.name_prefix}-eks"

  # EKS Access Entry에서 사용할 AWS 관리형 정책 ARN입니다.
  #
  # admin:
  # - 클러스터 관리자 권한
  #
  # developer:
  # - 리소스 수정 가능 권한
  #
  # viewer:
  # - 조회 권한
  access_policy_arns = {
    admin     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    developer = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    viewer    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  }

  # admin/developer/viewer 목록을 하나의 map으로 합칩니다.
  # 이렇게 하면 aws_eks_access_entry를 for_each로 깔끔하게 만들 수 있습니다.
  access_entries = merge(
    {
      for idx, arn in var.admin_principal_arns :
      "admin-${idx}" => {
        principal_arn = arn
        policy_arn    = local.access_policy_arns.admin
      }
    },
    {
      for idx, arn in var.developer_principal_arns :
      "developer-${idx}" => {
        principal_arn = arn
        policy_arn    = local.access_policy_arns.developer
      }
    },
    {
      for idx, arn in var.viewer_principal_arns :
      "viewer-${idx}" => {
        principal_arn = arn
        policy_arn    = local.access_policy_arns.viewer
      }
    }
  )
}