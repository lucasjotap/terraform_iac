output "kubernetes_namespace" {
  description = "The namespace the application was deployed into."
  value       = kubernetes_namespace.app_ns.metadata[0].name
}

output "service_name" {
  description = "The name of the Kubernetes service."
  value       = kubernetes_service.go_app_service.metadata[0].name
}

output "access_instructions" {
  description = "Instructions on how to access the application."
  value       = "Run 'minikube service ${kubernetes_service.go_app_service.metadata[0].name} -n ${kubernetes_namespace.app_ns.metadata[0].name}' to access the application."
}
