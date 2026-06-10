output "eks_addon_names" {
  description = "Installed EKS add-on names"

  value = concat(
    [for addon in aws_eks_addon.this : addon.addon_name],
    local.enable_ebs_csi_driver ? [aws_eks_addon.ebs_csi[0].addon_name] : []
  )
}

output "eks_addon_versions" {
  description = "Installed EKS add-on versions"

  value = merge(
    {
      for key, addon in aws_eks_addon.this :
      key => addon.addon_version
    },
    local.enable_ebs_csi_driver ? {
      "aws-ebs-csi-driver" = aws_eks_addon.ebs_csi[0].addon_version
    } : {}
  )
}

output "ebs_csi_role_arn" {
  description = "EBS CSI Driver Pod Identity IAM Role ARN"

  value = local.enable_ebs_csi_driver && var.enable_ebs_csi_pod_identity ? aws_iam_role.ebs_csi[0].arn : null
}