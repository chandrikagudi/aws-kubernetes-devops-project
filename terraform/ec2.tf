data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_key_pair" "devops" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.root}/../keys/devops-lab-key.pub")

  tags = {
    Name = "${var.project_name}-key"
  }
}

resource "aws_instance" "app_server_1" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_az1.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = aws_key_pair.devops.key_name
  associate_public_ip_address = true
  
lifecycle {
    ignore_changes = [ami]
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "${var.project_name}-server-1"
    Role = "kubernetes-node"
  }
}

resource "aws_instance" "app_server_2" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_az2.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = aws_key_pair.devops.key_name
  associate_public_ip_address = true

  lifecycle {
    ignore_changes = [ami]
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "${var.project_name}-server-2"
    Role = "kubernetes-node"
  }
}