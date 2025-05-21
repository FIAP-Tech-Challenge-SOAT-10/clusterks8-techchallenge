output "app_service_ip" {
  value = kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip
  description = "IP externo do serviço app"
}

output "app_service_name" {
  value       = kubectl_manifest.app_service.name
  description = "Nome do serviço da aplicação"
}
