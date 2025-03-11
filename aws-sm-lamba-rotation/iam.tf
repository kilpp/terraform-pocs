resource "aws_iam_role" "csi-experian-sm-rotation-iam-role" {
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

resource "aws_iam_policy" "csi-experian-sm-rotation-iam-policy" {
  name = "csi-experian-sm-rotation-iam-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.csi-experian-sm.arn]
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "csi-experian-sm-rotation-aim-role-pa" {
  role       = aws_iam_role.csi-experian-sm-rotation-iam-role.name
  policy_arn = aws_iam_policy.csi-experian-sm-rotation-iam-policy.arn
}