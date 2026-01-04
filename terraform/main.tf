terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
  }
}

provider "kubernetes" {
  # This will use the default kubeconfig path (~/.kube/config)
  # Ensure your kubectl is configured to point to minikube
}

provider "docker" {
  # This will use the local docker daemon
}

# Build the Docker image for our Go application
resource "docker_image" "go_data_app" {
  name = var.image_name
  build {
    context = "../go-app"
    tag     = ["${var.image_name}:latest"]
  }
}

# Create a dedicated namespace for our application
resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = var.namespace
  }
}

# Deploy the application using a Kubernetes Deployment
resource "kubernetes_deployment" "go_app_deployment" {
  # Ensure the image is built before the deployment is created
  depends_on = [docker_image.go_data_app]

  metadata {
    name      = "go-data-app-deployment"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
    labels = {
      App = var.app_name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        App = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          App = var.app_name
        }
      }

      spec {
        container {
          image = docker_image.go_data_app.name
          name  = "go-data-app-container"

          ports {
            container_port = 8080
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds      = 10
          }
        }
      }
    }
  }
}

# Expose the deployment using a NodePort service
resource "kubernetes_service" "go_app_service" {
  metadata {
    name      = "go-data-app-service"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }
  spec {
    selector = {
      App = kubernetes_deployment.go_app_deployment.spec[0].template[0].metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "NodePort"
  }
}
