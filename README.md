# ClearPointTraining Web Platform

## Overview

A production-style AWS infrastructure and CI/CD project that provisions cloud resources with Terraform and automatically builds, publishes, and deploys a Dockerized web application through GitHub Actions.

The project demonstrates an end-to-end cloud deployment workflow using Infrastructure as Code (IaC), containerization, federated AWS authentication, and automated application delivery.

Terraform provisions and manages the AWS infrastructure, while GitHub Actions handles continuous deployment. When code is pushed to the `main` branch, the pipeline authenticates to AWS through GitHub OIDC, builds a Docker image, tags the image with the Git commit SHA, pushes it to Amazon ECR, and deploys the new version to Amazon EC2 through AWS Systems Manager (SSM).

The architecture avoids long-lived AWS credentials in GitHub by using short-lived credentials obtained through AWS STS and an IAM OIDC trust relationship.

## Technologies Used

### GitHub Actions

GitHub Actions provides the CI/CD automation for the project. A workflow in `.github/workflows/deploy.yml` runs on pushes to the `main` branch and handles AWS authentication, Docker image creation, ECR publishing, and deployment to EC2.

### GitHub OIDC

GitHub OIDC is used to authenticate GitHub Actions to AWS without storing long-lived AWS access keys in the repository or GitHub secrets.

### AWS STS

AWS Security Token Service (STS) issues temporary credentials after the GitHub Actions workflow successfully assumes the dedicated CI/CD IAM role.

### Terraform

Terraform manages the AWS infrastructure as code. The configuration provisions and manages the EC2 instance, security group, IAM resources, instance profile, and related infrastructure. Terraform also uses a remote backend for shared state management.

### Docker

Docker packages the web application into a portable container image. The image is built from the project Dockerfile and tagged with the Git commit SHA during CI/CD deployments.

### Amazon ECR

Amazon Elastic Container Registry stores the application container images produced by the GitHub Actions workflow.

### Amazon EC2

Amazon EC2 hosts the running application container.

### AWS Systems Manager (SSM)

AWS Systems Manager is used for remote administration and automated deployment commands without requiring SSH access.

### AWS IAM

IAM roles and policies control access for both the EC2 instance and the GitHub Actions CI/CD workflow.

### Amazon S3

Amazon S3 stores the remote Terraform state file.

### AWS CLI

The AWS CLI is used by automation and the EC2 instance for AWS service operations such as ECR authentication and Systems Manager commands.

### Nginx

Nginx serves the static HTML application from inside the Docker container over HTTP on port 80.

## Architecture Overview

The platform separates infrastructure provisioning from application deployment.

Terraform provisions and manages the AWS infrastructure, including the EC2 instance, security group, IAM resources, and supporting configuration. EC2 user data performs the initial server bootstrap by installing the required software and starting the initial application container.

Ongoing application deployments are handled automatically through GitHub Actions.

```text
Developer
    |
    v
Git Push to main
    |
    v
GitHub Actions
    |
    v
GitHub OIDC
    |
    v
AWS STS / IAM Role
    |
    v
Docker Image Build
    |
    v
Amazon ECR
    |
    v
AWS Systems Manager (SSM)
    |
    v
Amazon EC2
    |
    v
Docker Container
    |
    v
Nginx Web Application
```

## CI/CD Pipeline

The application deployment pipeline is implemented with GitHub Actions and is triggered automatically when code is pushed to the `main` branch.

The pipeline performs the following steps:

1. Checks out the latest source code from the GitHub repository.
2. Authenticates to AWS using GitHub OIDC and assumes a dedicated IAM role through AWS STS.
3. Logs in to Amazon ECR.
4. Builds the application Docker image.
5. Tags the image with the Git commit SHA, providing traceability between source code and deployed container images.
6. Pushes the tagged Docker image to Amazon ECR.
7. Uses AWS Systems Manager (SSM) to send a deployment command to the EC2 instance.
8. The EC2 instance authenticates to ECR and pulls the new image.
9. The existing application container is replaced with a container running the newly deployed image.

This workflow provides an automated path from a Git commit to a running application without requiring manual deployment to the EC2 instance.

## Security Design

The project uses several AWS security practices to reduce reliance on long-lived credentials and direct server access.

- **GitHub OIDC authentication:** GitHub Actions authenticates to AWS using OpenID Connect (OIDC) rather than storing long-lived AWS access keys in GitHub.
- **Temporary AWS credentials:** AWS STS issues short-lived credentials after GitHub Actions assumes the dedicated CI/CD IAM role.
- **Restricted OIDC trust policy:** The IAM role trust relationship restricts access to the intended GitHub repository and `main` branch.
- **Least-privilege IAM:** IAM policies grant the permissions required for ECR image publishing and SSM deployment rather than broad administrative access.
- **SSM instead of SSH:** Application deployments and remote administration use AWS Systems Manager, eliminating the need to expose SSH port 22 for deployment access.
- **Remote Terraform state:** Terraform state is stored remotely in Amazon S3 rather than being committed to the Git repository.

## Repository Structure

```text
clearpointtraining-web-platform/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── docker/
│   ├── app/
│   │   └── index.html
│   └── Dockerfile
├── terraform/
│   ├── .terraform.lock.hcl
│   ├── backend.tf
│   ├── github-actions.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   ├── user-data.sh.tftpl
│   └── variables.tf
├── .gitignore
└── README.md
```

## Troubleshooting and Engineering Challenges

One of the most significant challenges in this project involved GitHub Actions authentication to AWS through OIDC.

The CI/CD workflow initially failed with:

`Not authorized to perform sts:AssumeRoleWithWebIdentity`

To isolate the problem, I verified the GitHub OIDC token claims, compared the token subject and audience against the live IAM trust policy, inspected the AWS OIDC provider configuration, reviewed CloudTrail events, and tested AWS STS directly.

The root cause was a misspelled OIDC audience condition in the IAM trust policy. The trust policy referenced `token.actions.gethubusercontent.com:aud` instead of `token.actions.githubusercontent.com:aud`.

After correcting the trust relationship with Terraform, GitHub Actions successfully assumed the CI/CD IAM role and the automated deployment completed end-to-end.

This troubleshooting process reinforced the importance of validating the first failing dependency in a deployment chain and using logs, token claims, IAM trust policies, and direct API testing to isolate authentication failures.

## Lessons Learned

During this project, I gained hands-on experience with:

- Designing and provisioning AWS infrastructure using Terraform.
- Managing Terraform state remotely with Amazon S3.
- Building and containerizing a web application with Docker and Nginx.
- Publishing versioned Docker images to Amazon ECR.
- Building an automated CI/CD pipeline with GitHub Actions.
- Authenticating GitHub Actions to AWS using OIDC and AWS STS.
- Designing IAM trust relationships and least-privilege permission policies.
- Using Git commit SHAs to create traceable container image versions.
- Deploying application updates to EC2 through AWS Systems Manager.
- Using SSM instead of SSH for remote administration and deployment.
- Troubleshooting IAM and OIDC authentication failures across GitHub and AWS.
- Using Git-based workflows to trigger automated application deployments.
- Separating infrastructure provisioning from ongoing application deployment.

