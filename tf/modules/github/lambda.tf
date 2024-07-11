resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambdabucketsandrobs1993"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "${path.root}/../../microservices/lambda-function/src/lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Adicionar a política que permite acessar SQS
  inline_policy {
    name = "lambda_sqs_access_policy"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = [
            "sqs:*"
          ],
          Resource = aws_sqs_queue.git_hub_repos_to_fork.arn
        }
      ]
    })
  }
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_lambda_function" "github_clone" {
  function_name = "github_clone_function"
  package_type  = "Image"
  image_uri     = "891377225324.dkr.ecr.us-east-1.amazonaws.com/repositorio-lambda:latest"
 /* s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_zip.key
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"*/
  role          = aws_iam_role.lambda_role.arn
  timeout       = 300

  environment {
    variables = {
      S3_BUCKET_NAME = "github_repos_bde5587dc8a847ae932633da52f9c43e"
      GITHUB_TOKEN   = "your_github_token"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
  event_source_arn = aws_sqs_queue.git_hub_repos_to_fork.arn
  function_name    = aws_lambda_function.github_clone.function_name
  batch_size       = 1
  enabled          = true
}