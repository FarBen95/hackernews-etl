resource "aws_instance" "backend_instance" {
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet_a.id
  ami                         = var.ami_id
  vpc_security_group_ids      = [aws_security_group.backend_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.backend_instance_profile.name
  user_data_replace_on_change = true
  force_destroy = true
  
  root_block_device {
    volume_size = 16
  }

  user_data = templatefile("${path.module}/ec2_init.tftpl", {
    s3_config_path = "s3://${aws_s3_bucket.config.bucket}"
    s3_dags_path   = "s3://${aws_s3_bucket.airflow.bucket}/dags"
    ssm_env_param  = aws_ssm_parameter.env_param.name
  })

  tags = {
    Name = "${var.project}-backend-instance"
  }
}

