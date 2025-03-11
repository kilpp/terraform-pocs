resource "aws_secretsmanager_secret" "csi-experian-sm" {
  name = "csi-experian-secret-manager-test"
}

resource "aws_secretsmanager_secret_version" "csi-experian-sm-version" {
  secret_id = aws_secretsmanager_secret.csi-experian-sm.id
  secret_string = jsonencode({
    "username" : "example_user",
    "password" : "ëxample_password"
  })
}

resource "aws_secretsmanager_secret_rotation" "csi-experian-sm-secret-rotation" {
  secret_id           = aws_secretsmanager_secret.csi-experian-sm.id
  rotation_lambda_arn = aws_lambda_function.csi-experian-sm-rotation-lambda-function.arn
  rotation_rules {
    automatically_after_days = 1
  }
}