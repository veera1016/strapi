variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
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

resource "aws_instance" "strapi" {
  ami           = "ami-04b70fa74e45c3917"  # Correct AMI ID for ap-south-1
  instance_type = "t2.medium"              # Changed to t2.medium
  key_name      = "Veera"                  # Your key pair name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  tags = {
    Name = "StrapiServer"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo apt-get update -y",
    "sudo apt-get install -y curl git",
    "curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
    "sudo apt-get install -y nodejs",
    "sudo npm install -g pm2",
    "sudo mkdir -p /srv/strapi",
    "sudo chown -R ubuntu:ubuntu /srv/strapi",
    "git clone -b revert-1-master https://github.com/veera1016/strapi.git /srv/strapi",
    "cd /srv/strapi && npm install -g npm@10.8.1",
    "cd /srv/strapi && npm run build",
    "pm2 start npm --name strapi -- start"
  ]
}


    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

output "instance_ip" {
  value = aws_instance.strapi.public_ip
}
