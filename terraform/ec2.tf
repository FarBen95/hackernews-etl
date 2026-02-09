resource "aws_instance" "backend-instance" {
  instance_type = var.instance_type
  subnet_id = aws_subnet.private_subnet.id
  ami = var.ami_id
  vpc_security_group_ids = [ aws_security_group.backend_sg.id ]
  # user_data = templatefile("${path.module}/init.sh", {
  #   s3_docker_path = aws_s3_bucket.docker.id
  #   s3_dags_path = var.s3_dags_path
  #   ssm_env_param = var.param_env
  # })

  tags = {
    Name = "${var.project}-backend-instance"
  }
}

