resource "aws_lambda_function" "experian-sm-rotation-lambda-function" {
  filename         = "lambda-code/experian-sm-rotation-lambda.zip"
  function_name    = "ExperianSecretManagerRotationFunction"
  role             = aws_iam_role.experian-sm-rotation-iam-role.arn
  handler          = "experian-sm-rotation-lambda.lambda_handler"
  runtime          = "python3.13"
  source_code_hash = data.archive_file.experian-lambda-function-file-zip.output_base64sha256
  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.experian-sm.arn
    }
  }
}

resource "aws_lambda_permission" "experian-sm-rotation-lambda-permission" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.experian-sm-rotation-lambda-function.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.experian-sm.arn
}

data "archive_file" "experian-lambda-function-file-zip" {
  type        = "zip"
  source_file = "lambda-code/experian-sm-rotation-lambda.py"
  output_path = "lambda-code/experian-sm-rotation-lambda.zip"
}