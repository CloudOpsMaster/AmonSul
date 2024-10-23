# Elasticsearch Deployment with Terraform and Ansible

This repository contains the code to deploy an EC2 instance on AWS, install Elasticsearch, and configure a cron job to move data older than 30 days to an S3 bucket.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- AWS credentials configured (e.g., `~/.aws/credentials`)
- SSH key (for accessing the EC2 instance)

## Usage

1. **Clone the repository**:
   ```bash
   git clone https://github.com/CloudOpsMaster/AmonSul.git
   cd AmonSul

2. **Initialize Terraform**:
    ```bash
    terraform init
3. **Deploy EC2 instance and S3 bucket**:
  ```bash
   terraform apply
