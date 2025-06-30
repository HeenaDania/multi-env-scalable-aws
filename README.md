# **Multi-Environment Scalable Web Application Infrastructure on AWS**

## **Overview**
This project provisions a scalable, multi-environment (dev, staging, prod) web app infrastructure on AWS using Terraform.

---

## **Folder Structure**
- **modules/** – Reusable Terraform modules (VPC, EC2, ALB, RDS, Security Groups)
- **envs/**
  - **dev/** – Dev environment configuration
  - **staging/** – Staging environment configuration
  - **prod/** – Production environment configuration
- **app/** – Static HTML app (Modern Photo Gallery)
- **.github/workflows/** – GitHub Actions CI/CD workflows
- **scripts/** – Helper scripts (e.g., Jenkins setup)

---

## **Getting Started**

**Prerequisites:**
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Git](https://git-scm.com/)
- [Jenkins](https://www.jenkins.io/) (for CI/CD, optional)

---

### **1. Bootstrap Terraform Backend**
- Go to `envs/` and run:
terraform init
terraform apply -auto-approve

- Copy the S3 bucket and DynamoDB table names for backend config.

---

### **2. Deploy an Environment**
- Go to the desired environment folder (e.g., `envs/dev`).
- Initialize and apply:
terraform init
terraform apply -var-file=terraform.tfvars


---

### **3. CI/CD**
- See `.github/workflows/terraform-ci.yml` for GitHub Actions.
- See `Jenkinsfile` for Jenkins pipeline.

---

## **Security**
- Do **not** commit secrets or `.tfstate` files.
- Use AWS IAM best practices for credentials.