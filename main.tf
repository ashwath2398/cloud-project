#hiring the aws crew
provider "aws" {
  region = "ap-south-1"
}

#create s3 bucket
resource "aws_s3_bucket" "my-cloud-bucket"  {   #nickname for terraform
   bucket = "my-cloud-bucket-ashwath" #actual bucket name
   force_destroy = true  #to delete non empty bucket
}
#unlock public access , by default blocked
resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_public_access_block" {
  bucket = "my-cloud-bucket-ashwath"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}  

#public access policy, invites everyone on internet to read objects from the bucket
resource "aws_s3_bucket_policy" "my-cloud-bucket-policy" {
    bucket = aws_s3_bucket.my-cloud-bucket.id
    depends_on = [ aws_s3_bucket_public_access_block.aws_s3_bucket_public_access_block ]
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid       = "PublicReadGetObject"
            Effect    = "Allow"
            Principal = "*"
            Action    = "s3:GetObject"
            Resource  = "${aws_s3_bucket.my-cloud-bucket.arn}/*"
        }
        ]
    })

}

#hosting website on s3 bucket 
resource "aws_s3_bucket_website_configuration" "my-cloud-bucket-website" {
  bucket = aws_s3_bucket.my-cloud-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  
}

#create dynamodb table
resource "aws_dynamodb_table" "cloud-portfolio" {
  name         = "cloud-portfolio"
  billing_mode = "PAY_PER_REQUEST" #pay as you go
  hash_key     = "id" #primary key

  attribute {
    name = "id"
    type = "S" #string type
  }
  
}


#zipping my python code for lambda function
data "archive_file" "zip_lambda" {
  type        = "zip"
  source_file = "main.py"
  output_path = "lambda_function.zip"
  
}

#actual lambda function
resource "aws_lambda_function" "visitor-counter" {
  function_name = "visitor-counter"
  filename      = data.archive_file.zip_lambda.output_path
  handler       = "main.lambda_handler" 
  runtime       = "python3.12"
  role          = aws_iam_role.iam_for_lambda.arn
  
}

#iam role for lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam-for-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
}

#iam policy attachment to link role with lambda
resource "aws_iam_role_policy" "dynamodb_access" {
  name = "dynamodb-access"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.cloud-portfolio.arn
      }
    ]
  })
  
}

#http api gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "visitor-counter-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [ "*" ]
    allow_methods = [ "GET", "POST", "PUT", "DELETE" ]
    allow_headers = [ "*" ]
  }
  
}

#deployment of api gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
  
}

#integrating lambda with api gateway
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.visitor-counter.arn
  integration_method = "POST"
  payload_format_version = "2.0"
  
}

#default route for api gateway
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  
}

#permission for api gateway to invoke lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor-counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  
}

output "website_url" {
  value = aws_s3_bucket.my-cloud-bucket.website_endpoint
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}