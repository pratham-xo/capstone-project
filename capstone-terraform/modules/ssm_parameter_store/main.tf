resource "aws_ssm_parameter" "sonarqube_token" {
  name        = "/sonarqube/token"
  description = "SonarQube token for authentication"
  type        = "SecureString"
  value       = var.sonarqube_token
}