resource "random_id" "this" {
  byte_length = 8
}

resource "tls_private_key" "strapi_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "strapi_keypair" {
  key_name   = "strapi-keypair-${random_id.this.hex}"
  public_key = tls_private_key.strapi_key.public_key_openssh
}

resource "aws_instance" "strapi_instance" {
  ami           = var.ami
  instance_type = "t2.medium"
  key_name      = aws_key_pair.strapi_keypair.key_name
  security_groups = [aws_security_group.strapi_sg.name]
  tags = {
    Name = "StrapiInstance-${random_id.this.hex}"
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install -y git
            curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
            sudo apt-get install -y nodejs
            sudo npm install -g pm2
            git clone https://github.com/PearlThoughts-DevOps-Internship/strapi /srv/strapi
            cd /srv/strapi
            sudo npm install
            pm2 start npm --name "strapi" -- start
            EOF

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.strapi_key.private_key_pem
      host        = self.public_ip
    }
  }

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group-${random_id.this.hex}"
  description = "Security group for Strapi EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Strapi Security Group-${random_id.this.hex}"
  }
}

output "strapi_private_key" {
  value = tls_private_key.strapi_key.private_key_pem
  sensitive = true
}
