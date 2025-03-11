resource "aws_lambda_function" "csi-experian-sm-rotation-lambda-function" {
  filename         = "lambda-code/csi-experian-sm-rotation-lambda.zip"
  function_name    = "CsiExperianSecretManagerRotationFunction"
  role             = aws_iam_role.csi-experian-sm-rotation-iam-role.arn
  handler          = "csi-experian-sm-rotation-lambda.lambda_handler"
  runtime          = "python3.13"
  source_code_hash = data.archive_file.csi-experian-lambda-function-file-zip.output_base64sha256
  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.csi-experian-sm.arn
    }
  }
}

resource "aws_lambda_permission" "csi-experian-sm-rotation-lambda-permission" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csi-experian-sm-rotation-lambda-function.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.csi-experian-sm.arn
}

data "archive_file" "csi-experian-lambda-function-file-zip" {
  type        = "zip"
  source_file = "lambda-code/csi-experian-sm-rotation-lambda.py"
  output_path = "lambda-code/csi-experian-sm-rotation-lambda.zip"
}