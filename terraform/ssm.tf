resource "aws_ssm_parameter" "env_param" {
  name        = "/${var.project}/${var.environment}/${var.param_env}"
  description = ".env secrets for backend instance"
  type        = "SecureString"
  value       = file("${path.module}/../config/.env")
}