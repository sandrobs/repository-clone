output "github_api_dns" {
  value = aws_lb.github_api.dns_name
}

output "lambda_function_name" {
  value = aws_lambda_function.github_clone.function_name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.git_hub_repos_to_fork.id
}