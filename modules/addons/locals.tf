locals {
  # EBS CSI Driver는 Pod Identity 연결 순서가 중요하므로
  # 일반 add-on 반복 생성 대상에서 제외합니다.
  #
  # 일반 add-on:
  # - vpc-cni
  # - coredns
  # - kube-proxy
  # - eks-pod-identity-agent
  #
  # 별도 add-on:
  # - aws-ebs-csi-driver
  general_eks_addon_set = toset([
    for addon in var.eks_addons : addon
    if addon != "aws-ebs-csi-driver"
  ])

  # EBS CSI Driver를 설치할지 여부입니다.
  enable_ebs_csi_driver = contains(var.eks_addons, "aws-ebs-csi-driver")

  # EBS CSI Driver Controller가 사용하는 Kubernetes ServiceAccount입니다.
  #
  # EKS Managed Add-on으로 aws-ebs-csi-driver를 설치하면
  # kube-system namespace 안에서 이 ServiceAccount를 사용합니다.
  ebs_csi_service_account = "ebs-csi-controller-sa"


  eso_namespace       = "external-secrets"
  eso_service_account = "external-secrets"
}