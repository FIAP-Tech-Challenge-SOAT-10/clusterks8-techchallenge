resource "kubectl_manifest" "namespace" {
  yaml_body = file("${path.module}/k8s/base/namespace.yaml")
}

# App
resource "kubectl_manifest" "app_configmap" {
  yaml_body = file("${path.module}/k8s/app/configmap.yaml")
}

resource "kubectl_manifest" "app_deployment" {
  yaml_body = file("${path.module}/k8s/app/app-deployment.yaml")
}

resource "kubectl_manifest" "app_service" {
  yaml_body = file("${path.module}/k8s/app/service.yaml")
}

# Redis
resource "kubectl_manifest" "redis_deployment" {
  yaml_body = file("${path.module}/k8s/redis/redis-deployment.yaml")
}

resource "kubectl_manifest" "redis_service" {
  yaml_body = file("${path.module}/k8s/redis/redis-service.yaml")
}

# Webhook
resource "kubectl_manifest" "webhook_deployment" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-deployment.yaml")
}

resource "kubectl_manifest" "webhook_configmap" {
  yaml_body = file("${path.module}/k8s/webhook/webhook-env-configmap.yaml")
}