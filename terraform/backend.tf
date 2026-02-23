# Remote state backend configuration
# This ensures state is stored remotely for team collaboration
# 
# NOTE: To enable remote state, first create the S3 bucket and DynamoDB table:
#
#   aws s3api create-bucket --bucket afrimart-terraform-state --region us-east-1
#   aws dynamodb create-table --table-name terraform-state-lock \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST
#
# Then uncomment the backend block below and run: terraform init
#
# For now, using local state for initial development.
# Uncomment below for remote state:

terraform {
  backend "s3" {
    bucket                 = "afrimart-terraform-state-1771161964"
    key                    = "prod/terraform.tfstate"
    region                 = "us-east-1"
    encrypt                = true
    skip_region_validation = true
  }
}
