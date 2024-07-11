resource "aws_sqs_queue" "git_hub_repos_to_fork" {
  name = "github-repos-to-fork"
  visibility_timeout_seconds = 300
}