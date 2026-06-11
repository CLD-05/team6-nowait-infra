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

output "lbc_role_arn" {
  description = "AWS Load Balancer Controller Pod Identity IAM Role ARN"
  value       = aws_iam_role.lbc.arn
}

output "lbc_policy_arn" {
  description = "AWS Load Balancer Controller IAM Policy ARN"
  value       = aws_iam_policy.lbc.arn
}

output "lbc_helm_release_name" {
  description = "AWS Load Balancer Controller Helm release name"
  value       = helm_release.lbc.name
}

output "metrics_server_helm_release_name" {
  description = "metrics-server Helm release name"
  value       = helm_release.metrics_server.name
}

output "eso_helm_release_name" {
  description = "External Secrets Operator Helm release name"
  value       = helm_release.eso.name
}

output "eso_role_arn" {
  description = "External Secrets Operator Pod Identity IAM Role ARN"
  value       = var.enable_eso_pod_identity ? aws_iam_role.eso[0].arn : null
}

output "eso_policy_arn" {
  description = "External Secrets Operator SSM read policy ARN"
  value       = var.enable_eso_pod_identity ? aws_iam_policy.eso[0].arn : null
}

output "eso_pod_identity_association_id" {
  description = "External Secrets Operator Pod Identity Association ID"
  value       = var.enable_eso_pod_identity ? aws_eks_pod_identity_association.eso[0].association_id : null
}

# ----------------------------------------
# NoWait API Pod Identity
# ----------------------------------------

output "nowait_api_role_arn" {
  description = "NoWait API Pod Identity IAM Role ARN"
  value       = var.enable_nowait_api_pod_identity ? aws_iam_role.nowait_api[0].arn : null
}

output "nowait_api_s3_policy_arn" {
  description = "NoWait API S3 image bucket policy ARN"
  value       = var.enable_nowait_api_pod_identity && var.image_bucket_arn != null ? aws_iam_policy.nowait_api_s3[0].arn : null
}

output "nowait_api_pod_identity_association_id" {
  description = "NoWait API Pod Identity Association ID"
  value       = var.enable_nowait_api_pod_identity ? aws_eks_pod_identity_association.nowait_api[0].association_id : null
}