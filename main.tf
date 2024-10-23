provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "elasticsearch_key" {
  key_name   = "elasticsearch_aws_key"
  public_key = tls_private_key.elasticsearch_key_pair.public_key_openssh
}

resource "tls_private_key" "elasticsearch_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_s3_bucket" "elasticsearch_backup_bucket" {
  bucket = "elasticsearch-s3-bucket-23102024-task" # Replace with your unique S3 bucket name
}

resource "aws_instance" "elasticsearch_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.elasticsearch_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update the package index
              apt-get update -y

              # Install required packages for Ansible
              apt-get install -y python3-pip
              pip3 install ansible boto3
              EOF

  tags = {
    Name = "ElasticsearchServer"
  }

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ${self.public_ip}, -u ubuntu --private-key ${tls_private_key.elasticsearch_key_pair.private_key_pem} ansible_setup.yml
    EOT
  }
}

output "instance_ip" {
  value = aws_instance.elasticsearch_instance.public_ip
}

output "private_key" {
  value = tls_private_key.elasticsearch_key_pair.private_key_pem
}
