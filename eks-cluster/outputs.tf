output "eks_cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "Nome do cluster EKS para ser usado no CI/CD"
}
