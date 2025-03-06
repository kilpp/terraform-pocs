output "bucket-id" {
  description = "The id of the bucket"
  value       = aws_s3_bucket.tf-bucket-test.id
}

output "bucket-arn" {
  description = "Arn of the bucket"
  value       = aws_s3_bucket.tf-bucket-test.arn
  sensitive   = true
}