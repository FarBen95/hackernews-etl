resource "aws_ssm_parameter" "env_param" {
  name = "/${var.project}/${var.environment}/${var.param_env}"
  description = ".env secrets for docker and airflow"
  type = "SecureString"
  value = file("${path.module}/../.env")
}