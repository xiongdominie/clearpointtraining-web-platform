#!/bin/bash

sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

sudo apt install awscli -y
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 509399624719.dkr.ecr.us-east-1.amazonaws.com

sudo docker pull 509399624719.dkr.ecr.us-east-1.amazonaws.com/project1-website:v3

sudo docker run -d --name webserver -p 80:80 509399624719.dkr.ecr.us-east-1.amazonaws.com/project1-website:v3