variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

resource "aws_instance" "strapi" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Correct AMI ID for ap-south-1
  instance_type = "t2.small"               # Changed to t2.small
  key_name      = "Veera"                  # Your key pair name

  tags = {
    Name = "StrapiServer"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo npm install -g yarn pm2
  EOF

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  resource "aws_security_group" "strapi_sg" {
  name        = "ashok-security-group"
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
}

output "instance_ip" {
  value = aws_instance.strapi.public_ip
}
