# Remote backend — S3 with DynamoDB state locking
# Prevents concurrent applies and provides state history

terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
