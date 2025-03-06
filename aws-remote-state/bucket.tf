resource "aws_s3_bucket" "remote-state-terraform" {
  bucket = "gk-remote-state-terraform"
}

resource "aws_s3_bucket_versioning" "remote-state-terraform-versionig" {
  bucket = aws_s3_bucket.remote-state-terraform.id
  versioning_configuration {
    status = "Enabled"
  }

}