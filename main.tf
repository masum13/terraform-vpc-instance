terraform {
  required_version = ">= 0.13.2 "
}

resource "aws_vpc" "module_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name}-${var.prefix}"
  }
}

resource "aws_security_group" "module_sg" {
  name        = "allow SSH,HTTP and HTTPS access"
  vpc_id      = aws_vpc.module_vpc.id
  description = "Module-Practice"
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "${var.name}-${var.prefix}-sg"
  }
}
resource "aws_subnet" "module_sn" {
  vpc_id                  = aws_vpc.module_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-${var.prefix}-sn"
  }
}

resource "aws_instance" "module_instance" {

  ami                         = var.ami
  instance_type               = "t2.micro" #each.value    ....to use for_each values.
  availability_zone           = "ap-south-1a"
  key_name                    = "TF-practice"
  subnet_id                   = aws_subnet.module_sn.id
  vpc_security_group_ids      = [aws_security_group.module_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install httpd -y 
                sudo echo "Module-Practice-1" | cat > /var/www/index.html
                sudo systemctl restart httpd
                EOF

  tags = {
    Name = "${var.name}-${var.prefix}-instance"
  }
}
