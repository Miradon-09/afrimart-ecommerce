# Setting Up Remote State for Terraform

## Current Status

The Terraform infrastructure is currently using **local state** (stored in `terraform.tfstate` file). This is fine for development and testing, but for team collaboration and production, remote state with locking is recommended.

---

## Why Remote State?

✅ **Benefits of Remote State**:
- Team collaboration (multiple developers)
- State locking prevents concurrent modifications
- Centralized backup of infrastructure state
- Version history and audit trail
- Separation from local machine

---

## Steps to Enable Remote State

### Step 1: Create S3 Bucket for State

```bash
# Create bucket in us-east-1
aws s3api create-bucket \
  --bucket afrimart-terraform-state-us-east-1 \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket afrimart-terraform-state-us-east-1 \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket afrimart-terraform-state-us-east-1 \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket afrimart-terraform-state-us-east-1 \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Step 2: Create DynamoDB Table for State Locking

```bash
# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 3: Enable Backend in Terraform

Edit `backend.tf` and uncomment the backend block:

```hcl
terraform {
  backend "s3" {
    bucket         = "afrimart-terraform-state-us-east-1"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    skip_region_validation = true
  }
}
```

### Step 4: Migrate State to Remote

```bash
# Reinitialize Terraform with new backend
terraform init

# When prompted, answer 'yes' to migrate existing state
# Do you want to copy existing state to the new backend?
```

### Step 5: Verify Remote State

```bash
# List objects in S3 bucket
aws s3 ls s3://afrimart-terraform-state-us-east-1/prod/

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-state-lock
```

---

## Troubleshooting

### Issue: "Bucket already exists in different region"

**Solution**: Use a unique bucket name:
```bash
TIMESTAMP=$(date +%s)
BUCKET_NAME="afrimart-terraform-state-${TIMESTAMP}"
# Use $BUCKET_NAME in backend.tf
```

### Issue: "Access Denied" when accessing S3

**Solution**: Ensure AWS credentials have S3 permissions:
```bash
# Check current AWS identity
aws sts get-caller-identity

# Verify S3 permissions
aws s3 ls
```

### Issue: "Failed to lock state"

**Solution**: Ensure DynamoDB table exists and is accessible:
```bash
aws dynamodb describe-table --table-name terraform-state-lock
```

---

## Using Multiple Environments (Staging/Production)

Once remote state is enabled, use workspaces:

```bash
# Create staging workspace
terraform workspace new staging

# Create production workspace
terraform workspace new production

# List workspaces
terraform workspace list

# Switch to staging
terraform workspace select staging

# Deploy to staging
terraform plan
terraform apply
```

Each workspace gets its own state file in S3:
- `staging/terraform.tfstate`
- `prod/terraform.tfstate`

---

## Best Practices

✅ **Do**:
- Always enable encryption for remote state
- Use versioning on S3 bucket
- Keep DynamoDB locking enabled
- Use separate workspaces for staging/production
- Regularly backup state files

❌ **Don't**:
- Share state files via email or chat
- Commit state files to Git
- Modify state files manually
- Delete DynamoDB lock table while Terraform is running

---

## Cleanup (If Needed)

To go back to local state:

```bash
# Migrate state back to local
terraform init

# When prompted, answer 'yes' to migrate

# Delete remote resources (optional)
aws s3 rm s3://afrimart-terraform-state-us-east-1 --recursive
aws s3api delete-bucket --bucket afrimart-terraform-state-us-east-1

aws dynamodb delete-table --table-name terraform-state-lock
```

---

## Current Configuration

**Status**: Local state  
**File**: `terraform.tfstate` (in project directory)  
**Backup**: `terraform.tfstate.backup` (previous state)

To enable remote state, follow the steps above.

---

## Support

For more information:
- [Terraform S3 Backend](https://www.terraform.io/docs/backends/types/s3.html)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [DynamoDB State Locking](https://www.terraform.io/docs/backends/state-locking.html)
