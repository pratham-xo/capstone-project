resource "aws_instance" "sonarqube" {
  ami = "ami-0ad2f19099a5db666"
  instance_type = "t3.medium"
  subnet_id = var.public_subnet_id


  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]

  key_name = var.key_name
  associate_public_ip_address = true
  user_data = file("${path.module}/user_data.sh")

  root_block_device {
  volume_size = 30
  volume_type = "gp3"
}

  tags = {
    Name = "sonarqube-instance"
  }
}


resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Security group for SonarQube instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP later
  }

  ingress {
    description = "SonarQube UI"

    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"] # Restrict later
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sonarqube-sg"
  }
}