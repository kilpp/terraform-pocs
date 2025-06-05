provider "aws" {
  region                     = "sa-east-1"
  access_key                 = "teste"
  secret_key                 = "teste"
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check    = true
}