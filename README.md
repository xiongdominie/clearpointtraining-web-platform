# ClearPointTraining Web Platform

A production-style cloud infrastructure project that deploys a Dockerized web application on AWS using Terraform.

This project demonstrates Infrastructure as Code (IaC) principles by provisioning AWS resources, deploying a containerized website from Amazon ECR, and managing infrastructure through a remote Terraform state stored in Amazon S3.

## Technologies Used

### Docker
We installed Docker on the EC2 instance and used it to package our HTML application into a custom Docker image based on the official Nginx image. This image was later pushed to Amazon ECR.

### AWS CLI
The AWS CLI was installed on the EC2 instance to authenticate with AWS and securely pull the custom Docker image from Amazon ECR during deployment.

### Terraform
Terraform was used as the Infrastructure as Code (IaC) tool. The project was organized into files such as `main.tf`, `iam.tf`, `backend.tf`, `outputs.tf`, `providers.tf`, `variables.tf`, and `terraform.tfvars`. Terraform provisions and manages the EC2 instance, Security Group, IAM Role, IAM Instance Profile, and policy attachments. The configuration uses an existing Amazon ECR repository for the application image and an existing Amazon S3 bucket for remote Terraform state.

### Amazon EC2
Amazon EC2 hosts the running Docker container. When the instance starts, it automatically pulls the custom Docker image from Amazon ECR and starts the web application.

### Amazon ECR
Amazon Elastic Container Registry (ECR) stores the custom Docker image built from our Dockerfile and HTML application.

### Amazon S3
Amazon S3 stores the remote Terraform state file. Terraform uses this state to keep track of the infrastructure it manages and compares it with both the Terraform configuration and the current AWS infrastructure during `terraform plan` and `terraform apply`.

### AWS IAM
An IAM Role was created with only the permissions required by the EC2 instance. The role was attached to an IAM Instance Profile, which was then attached to the EC2 instance.

### AWS Systems Manager (SSM)
The IAM Role includes Systems Manager permissions, allowing secure remote administration of the EC2 instance without requiring SSH access.

### Nginx
The official Nginx Docker image serves the HTML website. During the Docker image build, our HTML files were copied into Nginx's web root (`/usr/share/nginx/html`), allowing Nginx to serve the website over HTTP on port 80.

## Architecture Overview

The deployment process follows these steps:

1. Terraform provisions the AWS infrastructure.
2. AWS creates the requested infrastructure resources.
3. The EC2 instance launches Ubuntu Linux.
4. During startup, the EC2 instance executes a   
Terraform-provided user data script that installs Docker and the AWS CLI, authenticates with Amazon ECR, pulls the application image, and starts the container.
5. The EC2 instance authenticates with Amazon ECR and pulls the custom Docker image.
6. Docker creates and starts a container from the custom image.
7. Inside the container, Nginx serves the HTML website on port 80.
8. Users access the website through the EC2 public IP address.

## Repository Structure

```text
clearpointtraining-web-platform/
├── app/
│   └── index.html
├── terraform/
│   ├── backend.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── user-data.sh.tftpl
└── README.md
```

## Lessons Learned

During this project, I gained hands-on experience with:

- Writing Infrastructure as Code (IaC) using Terraform.
- Provisioning and managing AWS infrastructure through Terraform.
- Building custom Docker images using the official Nginx base image.
- Publishing Docker images to Amazon Elastic Container Registry (ECR).
- Automatically deploying containers to Amazon EC2 using Terraform user data.
- Managing AWS permissions using IAM Roles and Instance Profiles.
- Using AWS Systems Manager (SSM) for secure remote administration without SSH.
- Configuring and using a remote Terraform backend with Amazon S3.
- Understanding Terraform state, infrastructure drift, and the Terraform workflow (`init`, `plan`, and `apply`).

## Key Takeaways

Throughout this project, I developed a deeper understanding of cloud infrastructure and Infrastructure as Code (IaC). Some of the most important concepts I learned include:

- Infrastructure is the collection of cloud resources that support an application.
- Terraform defines the desired infrastructure, while AWS provisions the actual cloud resources.
- A Docker image is a reusable blueprint, while a container is a running instance of that image.
- Nginx serves the application's HTML files from within the Docker container.
- IAM Roles provide identities for AWS resources, while IAM Policies define what those identities are allowed to do.
- Terraform state tracks the infrastructure it manages and allows Terraform to compare the desired configuration with the current infrastructure.
- Storing Terraform state remotely in Amazon S3 allows multiple engineers to collaborate using the same source of truth.