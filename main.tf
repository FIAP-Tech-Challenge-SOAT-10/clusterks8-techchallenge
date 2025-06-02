# NAMESPACE
resource "kubectl_manifest" "namespace" {
  yaml_body = file("${path.module}/k8s/base/namespace.yaml")
}

# App
resource "kubectl_manifest" "app_configmap" {
  yaml_body = file("${path.module}/k8s/apps/configmap.yaml")
  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "app_deployment" {
  yaml_body = file("${path.module}/k8s/apps/app-deployment.yaml")
  depends_on = [
    kubectl_manifest.app_configmap,
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "app_service" {
  yaml_body = file("${path.module}/k8s/apps/service.yaml")
  depends_on = [
    kubectl_manifest.app_deployment,
    kubectl_manifest.namespace
  ]
}

# Redis
resource "kubectl_manifest" "redis_deployment" {
  yaml_body = file("${path.module}/k8s/redis/redis-deployment.yaml")
  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "redis_service" {
  yaml_body = file("${path.module}/k8s/redis/redis-service.yaml")
  depends_on = [
    kubectl_manifest.redis_deployment,
    kubectl_manifest.namespace
  ]
}

# Webhook
resource "kubectl_manifest" "webhook_deployment" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-deployment.yaml")
  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "webhook_service" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-service.yaml")
  depends_on = [
    kubectl_manifest.webhook_deployment,
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "webhook_ingress" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-ingress.yaml")
  depends_on = [
    kubectl_manifest.webhook_service,
    kubectl_manifest.namespace
  ]
}
