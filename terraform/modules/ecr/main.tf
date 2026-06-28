resource "aws_ecr_repository" "capstone_ecr" {
  name         = "capstone-ecr"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}