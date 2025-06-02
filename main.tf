resource "kubectl_manifest" "namespace" {
  yaml_body = file("${path.module}/k8s/base/namespace.yaml")
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

# App
resource "kubectl_manifest" "app_configmap" {
  yaml_body = file("${path.module}/k8s/apps/configmap.yaml")
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "kubectl_manifest" "app_deployment" {
  yaml_body = file("${path.module}/k8s/apps/app-deployment.yaml")
  depends_on = [
    aws_eks_node_group.node_group,
    kubectl_manifest.app_configmap
  ]
}

resource "kubectl_manifest" "app_service" {
  yaml_body = file("${path.module}/k8s/apps/service.yaml")
  depends_on = [
    aws_eks_node_group.node_group,
    kubectl_manifest.app_deployment
  ]
}

# Redis
resource "kubectl_manifest" "redis_deployment" {
  yaml_body = file("${path.module}/k8s/redis/redis-deployment.yaml")
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "kubectl_manifest" "redis_service" {
  yaml_body = file("${path.module}/k8s/redis/redis-service.yaml")
  depends_on = [
    aws_eks_node_group.node_group,
    kubectl_manifest.redis_deployment
  ]
}

# Webhook
resource "kubectl_manifest" "webhook_deployment" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-deployment.yaml")
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "kubectl_manifest" "webhook_service" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-service.yaml")
  depends_on = [
    aws_eks_node_group.node_group,
    kubectl_manifest.webhook_deployment
  ]
}

resource "kubectl_manifest" "webhook_ingress" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-ingress.yaml")
  depends_on = [
    aws_eks_node_group.node_group,
    kubectl_manifest.webhook_service
  ]
}
