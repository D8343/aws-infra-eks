output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description = "Security group ID attached to the EKS cluster"
}
