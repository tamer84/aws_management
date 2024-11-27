data "aws_caller_identity" "current" {}

# tfsec:ignore:aws-kms-auto-rotate-keys
resource "aws_kms_key" "terraform_bucket_key" {
  description             = "This key is used to encrypt the terraform bucket"
  deletion_window_in_days = 10
}

# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# LockId table terraform
resource "aws_dynamodb_table" "terraform-lock" {
  name           = "terraform-lock-${data.aws_caller_identity.current.account_id}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  server_side_encryption {
    enabled = true // enabled server side encryption
  }
  point_in_time_recovery {
    enabled = true
  }
}