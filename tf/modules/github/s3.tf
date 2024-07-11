resource "aws_s3_bucket" "github_repos" {
  bucket = "repositoriosgithub19932903"

  tags = {
    Name        = "repositoriosgithub19932903"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = "Sandro BS"
    UpdatedAt   = "2024-07-09"
  }
}
