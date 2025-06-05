resource "aws_secretsmanager_secret" "experian-sm" {
  name = "experian-sm-secret"
}

resource "aws_secretsmanager_secret_version" "experian-sm-version" {
  secret_id = aws_secretsmanager_secret.experian-sm.id
  secret_string = jsonencode({
    "username" : "example_user",
    "password" : "ëxample_password"
  })
}

resource "aws_secretsmanager_secret_rotation" "experian-sm-secret-rotation" {
  secret_id           = aws_secretsmanager_secret.experian-sm.id
  rotation_lambda_arn = aws_lambda_function.experian-sm-rotation-lambda-function.arn
  rotation_rules {
    automatically_after_days = 1
  }
}