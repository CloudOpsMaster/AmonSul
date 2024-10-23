provider "aws" {
  region = "us-east-1"  # Specify your AWS region here
}

# Create an SSH key pair (use your public key for connection)
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Update path to your public SSH key
}

# Define an EC2 instance
resource "aws_instance" "elastic_search_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Ubuntu AMI, change it to your region's AMI
  instance_type = "t2.micro"               # Instance type (for small-scale testing)
  key_name      = aws_key_pair.deployer_key.key_name  # Use the created SSH key pair for access

  tags = {
    Name = "ElasticSearch-Server"  # Tag for easy identification
  }

  # Define the security group for SSH and Elasticsearch access
  vpc_security_group_ids = [aws_security_group.es_sg.id]

  # Provision EC2 with Ansible via remote-exec
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y ansible",
      "ansible-playbook /tmp/playbook.yml"  # Automatically run Ansible playbook after provisioning
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"                  # Default user for Ubuntu AMIs
      private_key = file("~/.ssh/id_rsa")     # Path to your private SSH key
      host        = aws_instance.elastic_search_instance.public_ip  # Connect to the public IP of the instance
    }

    # Copy the playbook to the EC2 instance
    provisioner "file" {
      source      = "playbook.yml"
      destination = "/tmp/playbook.yml"  # Playbook location on the instance
    }
  }
}

# Define a security group for EC2 instance
resource "aws_security_group" "es_sg" {
  name_prefix = "elastic-search-sg"

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for SSH from any IP
  }

  # Allow access to Elasticsearch port
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for HTTP access from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Define an S3 bucket with lifecycle rules for Elasticsearch data
resource "aws_s3_bucket" "elastic_search_data" {
  bucket = "es-data-bucket"
  acl    = "private"  # Restrict access to the bucket

  versioning {
    enabled = true  # Enable versioning for safety
  }

  # Automatically delete objects older than 30 days
  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}

# Output the public IP of the EC2 instance
output "ec2_instance_public_ip" {
  value = aws_instance.elastic_search_instance.public_ip
}
