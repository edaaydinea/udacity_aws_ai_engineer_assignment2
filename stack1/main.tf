provider "aws" {
  region = "us-east-1"  # Change this to your desired region # UPDATED
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "aurora_serverless" {

  source = "../modules/database"

  cluster_identifier = "my-aurora-serverless"
  vpc_id = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  database_name    = "myapp"
  master_username  = "dbadmin"
  max_capacity     = 1
  min_capacity     = 0.5
  allowed_cidr_blocks = [data.aws_vpc.default.cidr_block]
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "bedrock-kb-${data.aws_caller_identity.current.account_id}"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = local.bucket_name
  acl    = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}