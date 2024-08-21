# Terraform Gitea docker in AWS EC2

This is a practice project to use Terraform to automate deploy docker container in AWS EC2.

These are basic steps. [Work In Progress]

1. Create EC2 with security group via Terraform. [main.tf]
2. Create VPC. [vpc.tf]
3. Create Application Load Balancer via Terraform. [alb.tf]
4. Create Gitea docker container via Terraform. [install_docker.sh]

# Commands

Initialize Terraform
```
terraform init
```

Plan the Terraform
```
terraform plan
```

Apply the Terraform
```
terraform apply
```

Destroy the Terraform
```
terraform destroy
```