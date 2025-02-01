# Permissão para a função Lambda ser invocada pelo API Gateway
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "hackathon-gera-urlpreassinada"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.presigned_url_api.execution_arn}/*/*"
}

# Criação da API Gateway REST API
resource "aws_api_gateway_rest_api" "presigned_url_api" {
  name        = "Pos Tech Hackathon - API Gateway"
  description = "API Gateway - Hackathon FIAP"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Recurso principal /presigned-url
resource "aws_api_gateway_resource" "apigateway_presigned_url_resource" {
  rest_api_id = aws_api_gateway_rest_api.presigned_url_api.id
  parent_id   = aws_api_gateway_rest_api.presigned_url_api.root_resource_id
  path_part   = "presigned-url"
}

# Método GET para /presigned-url
resource "aws_api_gateway_method" "apigateway_presigned_url_method" {
  rest_api_id   = aws_api_gateway_rest_api.presigned_url_api.id
  resource_id   = aws_api_gateway_resource.apigateway_presigned_url_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integração com Lambda para /presigned-url
resource "aws_api_gateway_integration" "apigateway_presigned_url_integration" {
  rest_api_id             = aws_api_gateway_rest_api.presigned_url_api.id
  resource_id             = aws_api_gateway_resource.apigateway_presigned_url_resource.id
  http_method             = aws_api_gateway_method.apigateway_presigned_url_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:369780787289:function:hackathon-gera-urlpreassinada/invocations"
}

# Criar a resposta do método
resource "aws_api_gateway_method_response" "apigateway_presigned_url_method_response" {
  rest_api_id = aws_api_gateway_rest_api.presigned_url_api.id
  resource_id = aws_api_gateway_resource.apigateway_presigned_url_resource.id
  http_method = aws_api_gateway_method.apigateway_presigned_url_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Criar a resposta de integração
resource "aws_api_gateway_integration_response" "apigateway_presigned_url_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.presigned_url_api.id
  resource_id = aws_api_gateway_resource.apigateway_presigned_url_resource.id
  http_method = aws_api_gateway_method.apigateway_presigned_url_method.http_method
  status_code = aws_api_gateway_method_response.apigateway_presigned_url_method_response.status_code

  response_templates = {
    "application/json" = jsonencode({
      message = "Success"
    })
  }
}

# Criação do Deployment da API
resource "aws_api_gateway_deployment" "apigateway_presigned_url_deployment" {
  depends_on = [
    aws_api_gateway_integration.apigateway_presigned_url_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.presigned_url_api.id
  stage_name  = "prod"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "CognitoAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.presigned_url_api.id
  provider_arns = aws_cognito_user_pool.user_pool.arn

  depends_on = [aws_cognito_user_pool.user_pool]
}