variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "go-data-app"
}

variable "image_name" {
  description = "The name of the Docker image to build."
  type        = string
  default     = "go-data-app"
}

variable "namespace" {
  description = "The Kubernetes namespace to deploy the application into."
  type        = string
  default     = "go-data-app-ns"
}
