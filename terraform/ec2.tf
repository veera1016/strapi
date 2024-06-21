variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

resource "aws_instance" "strapi" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Correct AMI ID for ap-south-1
  instance_type = "t2.medium"
  key_name      = "Veera"  # Your key pair name
  security_groups = [aws_security_group.strapi_sg.name]

  tags = {
    Name = "StrapiServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y curl",
      "curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g pm2",
      "git clone https://github.com/veera1016/strapi.git /srv/strapi",
      "cd /srv/strapi && npm install",
      "cd /srv/strapi && npm run build",
      "pm2 start npm --name strapi -- start"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group"
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

