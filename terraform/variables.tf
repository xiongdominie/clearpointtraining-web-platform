variable "aws_region" {
  description = "AWS region where infrastructure will be created"
  type        = string

}

variable "instance_name" {
  description = "Name of the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "docker_image" {
  description = "Docker image to deploy from Amazon ECR"
  type        = string
}
