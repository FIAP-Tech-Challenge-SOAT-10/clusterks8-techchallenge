output "app_service_name" {
  value       = kubectl_manifest.app_service.name
  description = "Nome do serviço da aplicação"
}
