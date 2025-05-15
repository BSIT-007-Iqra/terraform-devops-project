data "aws_ami" "os_image" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*amd64*"]
  }
}

# key pair fot instance
resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = file("terra-key.pub") # MUST be the content of your public key (not .pem)
}

# VPC & Security group
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf-vpc-automated"
  }

}
resource "aws_security_group" "allow_user_to_connect" {
  name        = "allow TLS"
  description = "Allow user to connect"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outgoing traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 80 allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 443 allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "stf-sg-automated"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Adjust based on your region
  map_public_ip_on_launch = true

  tags = {
    Name = "automated-subnet"
  }
}


data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}


resource "aws_instance" "test_instance" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.my_enviroment == "prod" ? "t2.small" : "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_user_to_connect.id]
  subnet_id                   = aws_subnet.my_subnet.id # <- ADD THIS
  associate_public_ip_address = true

  user_data = file("${path.module}/scriptfile.sh")

  tags = {
    Name = "Terra-ec2-Automate"
  }

  root_block_device {
    volume_size           = var.my_enviroment == "prod" ? 20 : var.ec2_default_root_storage_size
    volume_type           = var.ec2_default_root_storage_type
    delete_on_termination = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("terra-key")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "echo 'Hello from Terraform Provisioners!' | sudo tee /var/www/html/index.html"
    ]
  }
}



# resource "aws_instance" "test_instance" {
#   ami           = data.aws_ssm_parameter.ubuntu_ami.value  #
#   instance_type   = var.my_enviroment == "prod" ? "t2.small" : "t2.micro"  
#   key_name        = var.key_name
#   vpc_security_group_ids = [aws_security_group.allow_user_to_connect.id]
#   user_data = file("${path.module}/scriptfile.sh")
#   tags = {
#     Name = "Terra-ec2-Automate"
#   }
#   root_block_device {
#     volume_size           = var.my_enviroment == "prod" ? 20 : var.ec2_default_root_storage_size
#     volume_type           = var.ec2_default_root_storage_type
#     delete_on_termination = true
#   }
#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file("terra-key")
#     host        = self.public_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update -y",
#       "sudo apt install -y apache2",
#       "sudo systemctl start apache2",
#       "sudo systemctl enable apache2",
#       "echo 'Hello from Terraform Provisioners!' | sudo tee /var/www/html/index.html"
#     ]
#   }
# }
