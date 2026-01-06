# Terraform Go Data App on Minikube
![Uploading image.png…]()

This project demonstrates a simple data-engineering-style application built with Go, containerized with Docker, and deployed to a local Minikube Kubernetes cluster using Terraform.

The Go application runs a web server that generates mock data records and exposes them via an API endpoint. Terraform is used to manage the entire lifecycle of the infrastructure, from building the Docker image to deploying it on Kubernetes.

## Project Structure

```
.
├── go-app/
│   ├── main.go         # The Go web server code
│   ├── go.mod          # Go module definitions
│   ├── go.sum          # Go module checksums
│   └── Dockerfile      # Dockerfile for building the Go app
├── terraform/
│   ├── main.tf         # Main Terraform configuration for deployment
│   ├── variables.tf    # Terraform variable definitions
│   └── outputs.tf      # Terraform output definitions
└── README.md           # This file
```

## Go Application Breakdown

The application is a simple web server written in Go (`go-app/main.go`). Here is a breakdown of its execution flow:

1.  **`main()` function**: This is the entry point of the application.
    *   It seeds the random number generator.
    *   It creates a new HTTP request multiplexer (router).
    *   It registers two handler functions:
        *   `/health` is handled by `healthCheckHandler`.
        *   `/api/v1/data` is handled by `dataHandler`.
    *   It starts the HTTP server on port `8080`.

2.  **`healthCheckHandler(...)`**:
    *   This is a simple handler used by Kubernetes for liveness probes.
    *   It responds with a `200 OK` status to indicate that the application is running.

3.  **`dataHandler(...)`**: This is the core data generation logic.
    *   When a request hits the `/api/v1/data` endpoint, this function is executed.
    *   It creates an instance of the `DataRecord` struct.
    *   It populates the struct with a new UUID, a random integer, and the current UTC timestamp.
    *   **Simulated Processing**: It logs the generated data to standard output using `log.Printf()`. In a real-world scenario, this is where data processing or forwarding to another service (like Kafka or a database) would happen. You can view these logs from the Kubernetes pod.
    *   Finally, it serializes the `DataRecord` struct into a JSON object and sends it back as the HTTP response.

## Prerequisites

*   [Go](https://golang.org/doc/install) (version 1.20+)
*   [Docker](https://docs.docker.com/get-docker/)
*   [Minikube](https://minikube.sigs.k8s.io/docs/start/)
*   [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Execution Steps

### 1. Start Minikube

First, ensure your local Kubernetes cluster is running.

```bash
minikube start
```

### 2. Set Docker Environment

Configure your local environment to use Minikube's internal Docker daemon. This is a critical step that allows Terraform to build the image in a context that Minikube can access without a separate registry.

```bash
eval $(minikube -p minikube docker-env)
```
**Note**: You must run this command in the same terminal session where you will run Terraform.

### 3. Initialize Terraform

Navigate to the `terraform` directory and initialize the providers.

```bash
cd terraform
terraform init
```

### 4. Deploy the Application

Apply the Terraform configuration to build the Docker image and deploy the resources to Minikube.

```bash
terraform apply --auto-approve
```

Terraform will perform the following actions:
- Build the Docker image from `../go-app`.
- Create a Kubernetes namespace called `go-data-app-ns`.
- Create a Kubernetes deployment to run 2 replicas of your application pod.
- Create a Kubernetes service to expose the application.

### 5. Access the Service

After the `apply` command finishes, Terraform will display an `access_instructions` output. Run the command provided:

```bash
minikube service go-data-app-service -n go-data-app-ns
```

This command will automatically open a URL in your web browser. You will see "OK". To get mock data, navigate to the `/api/v1/data` endpoint (e.g., `http://127.0.0.1:12345/api/v1/data`).

### 6. Clean Up

To tear down all the resources created by this project, run the destroy command from the `terraform` directory.

```bash
terraform destroy --auto-approve
```

To unset the Docker environment variable, you can run:

```bash
eval $(minikube docker-env -u)
```
