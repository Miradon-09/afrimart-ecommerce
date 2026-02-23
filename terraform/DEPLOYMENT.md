# AfriMart Infrastructure Deployment Guide

## Overview

This guide provides step-by-step instructions to deploy the complete AWS infrastructure for the AfriMart e-commerce platform using Terraform, following the Phase 1 requirements from STUDENT_ASSIGNMENT.md.

**Total Infrastructure Cost**: ~$53/month (within $50 budget with optimizations)  
**Estimated Deployment Time**: 10-15 minutes  
**Terraform Configuration**: ✅ Validated

## Pre-Deployment Checklist

### 1. AWS Account Setup

- [ ] AWS account created and active
- [ ] AWS billing enabled
- [ ] Budget alert set to $60 (to stay within $50 limit)

```bash
# Verify AWS access
aws sts get-caller-identity
aws ec2 describe-instances --max-results 1
```

### 2. AWS Credentials Configuration

```bash
# Option A: Using AWS CLI (recommended)
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json

# Option B: Using environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"

# Verify credentials
aws sts get-caller-identity
```

### 3. Install Required Tools

```bash
# Check Terraform version (need v1.0+)
terraform version

# Install Terraform (if needed)
# macOS: brew install terraform
# Linux: https://www.terraform.io/downloads
# Windows: https://www.terraform.io/downloads

# Check AWS CLI
aws --version

# Install AWS CLI (if needed)
# macOS: brew install awscli
# Linux: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```

### 4. Backend Infrastructure (Optional but Recommended)

If you want to use remote state (recommended for team collaboration):

```bash
# Create S3 bucket for state
S3_BUCKET="afrimart-terraform-state-$(date +%s)"
aws s3api create-bucket \
  --bucket $S3_BUCKET \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $S3_BUCKET \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket $S3_BUCKET \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Update backend.tf with your bucket name
# Then run: terraform init
```

## Deployment Steps

### Step 1: Initialize Terraform

```bash
cd terraform

# Initialize Terraform (downloads AWS provider)
terraform init

# If using remote backend, it will prompt to migrate state
# Press 'yes' to confirm
```

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 2: Review and Update Variables

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables (use your favorite editor)
cat terraform.tfvars
```

Update these values:

```hcl
region       = "us-east-1"
project_name = "afrimart"
db_username  = "afrimart"
db_password  = "YOUR_SECURE_PASSWORD"  # Change this!
```

⚠️ **IMPORTANT**: Use a strong password for RDS:
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers, and special characters
- Example: `MyAfriMart@2024`

### Step 3: Plan Infrastructure

```bash
# Generate execution plan
terraform plan -out=tfplan

# Review the plan:
# - Number of resources to create
# - Resource names and configurations
# - No changes to existing resources (first run)
```

**Expected resources count**: ~25 resources

**Key resources**:
- 1 VPC
- 2 Public Subnets
- 2 Private Subnets
- 1 Internet Gateway
- 1 NAT Gateway
- 2 Route Tables
- 4 Security Groups
- 1 RDS Instance
- 1 Redis Cluster
- 1 S3 Bucket
- 1 Load Balancer
- 1 Launch Template
- 1 Auto Scaling Group
- Plus various route associations and subnet groups

### Step 4: Apply Infrastructure

```bash
# Apply the plan (creates all resources)
terraform apply tfplan

# Enter 'yes' when prompted
```

**Expected duration**: 8-12 minutes

**Progress indicators**:
- 1-2 min: VPC and networking
- 2-3 min: Security groups
- 3-5 min: RDS database (longest step)
- 1-2 min: ElastiCache Redis
- 1-2 min: Load Balancer
- 1-2 min: EC2 instances and ASG

**Warning messages** (normal):
```
aws_nat_gateway.nat: Still creating...
aws_db_instance.postgres: Still creating...
aws_elasticache_cluster.redis: Still creating...
```

### Step 5: Retrieve Outputs

```bash
# Display all outputs
terraform output

# Save outputs to file
terraform output > deployment-outputs.txt

# Get specific outputs
terraform output application_url
terraform output rds_endpoint
terraform output redis_endpoint
terraform output load_balancer_dns
```

**Sample outputs**:
```
application_url = "http://afrimart-clb-1234567890.us-east-1.elb.amazonaws.com"
load_balancer_dns = "afrimart-clb-1234567890.us-east-1.elb.amazonaws.com"
rds_endpoint = "afrimart-db.cpvgqxyz1234.us-east-1.rds.amazonaws.com:5432"
redis_endpoint = "afrimart-redis.ab1cde.ng.0001.use1.cache.amazonaws.com"
s3_bucket_name = "afrimart-uploads-1234567890"
vpc_id = "vpc-1234567890abcdef0"
```

## Post-Deployment Verification

### 1. Verify Infrastructure in AWS Console

```bash
# VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=afrimart-vpc"

# Subnets
aws ec2 describe-subnets --filters "Name=tag:Name,Values=afrimart-*"

# Security Groups
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=afrimart-*"

# Load Balancer
aws elb describe-load-balancers --load-balancer-names afrimart-clb

# RDS
aws rds describe-db-instances --db-instance-identifier afrimart-db

# ElastiCache
aws elasticache describe-cache-clusters --cache-cluster-id afrimart-redis

# S3
aws s3 ls | grep afrimart-uploads

# Auto Scaling Group
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names afrimart-asg
```

### 2. Test Load Balancer Health

```bash
# Get load balancer DNS
LB_DNS=$(terraform output -raw load_balancer_dns)

# Test health endpoint
curl -i http://$LB_DNS/health

# Expected response: HTTP/1.1 200 OK (or 503 if app not configured yet)
```

### 3. Verify Database Connectivity

```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
HOST=$(echo $RDS_ENDPOINT | cut -d: -f1)
DB_USER=$(terraform output -raw rds_username)

# Install postgres client if needed
# macOS: brew install postgresql
# Ubuntu: sudo apt-get install postgresql-client
# CentOS: sudo yum install postgresql

# Test database connection (requires password from terraform.tfvars)
psql -h $HOST -U $DB_USER -d postgres -c "SELECT version();"
```

### 4. Check Cost

```bash
# View current costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# Set up billing alert (if not already done)
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget.json
```

## Common Issues & Solutions

### Issue 1: "Error: InvalidParameterValue" on AMI

**Cause**: AMI ID not available in region

**Solution**:
```bash
# Find correct AMI for your region
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name]' \
  --output text

# Update modules/compute/variables.tf with new AMI ID
```

### Issue 2: "Error: error creating RDS instance"

**Causes**:
- Insufficient RDS quota (default: 40)
- Network issues
- Security group misconfiguration

**Solutions**:
```bash
# Check RDS quota
aws service-quotas get-service-quota \
  --service-code rds \
  --quota-code L-7B6409FD

# If needed, request quota increase in AWS Console
# Services > Service Quotas > RDS > DB instances
```

### Issue 3: Load Balancer shows 0 healthy instances

**Cause**: Application not responding to /health or security group issue

**Solutions**:
```bash
# Check instance status
aws ec2 describe-instance-status --query 'InstanceStatuses[*].[InstanceId,InstanceStatus.Status]'

# Check ASG instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names afrimart-asg \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus]'

# SSH into instance and check application logs
# (requires security group update to allow SSH)
```

### Issue 4: "Error: error acquiring the state lock"

**Cause**: Another Terraform process has the lock

**Solution**:
```bash
# Force unlock (use with caution!)
terraform force-unlock LOCK_ID

# Or wait for the other process to complete
```

## Managing Infrastructure

### Scale Up/Down

```bash
# Edit desired capacity in compute module or update via CLI
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name afrimart-asg \
  --desired-capacity 3
```

### Update Configuration

```bash
# Edit variable in terraform.tfvars
# Then plan and apply
terraform plan
terraform apply
```

### Destroy Resources (Be Careful!)

```bash
# Plan destruction
terraform plan -destroy

# Destroy all resources
terraform destroy

# Or destroy specific resource
terraform destroy -target=module.compute
```

## Monitoring After Deployment

### Key Metrics to Monitor

```bash
# EC2 CPU Utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=afrimart-asg \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# RDS CPU
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=afrimart-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Load Balancer
aws cloudwatch get-metric-statistics \
  --namespace AWS/ELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancerName,Value=afrimart-clb \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## Cost Optimization Tips

### Immediate Savings (save $20-30/month)

1. **Remove NAT Gateway** (save $32/month)
   ```bash
   # Use VPC endpoints instead (for S3)
   # Or accept no internet access for private instances
   ```

2. **Reduce ASG capacity** (save $4/month)
   ```bash
   # Change desired capacity from 2 to 1
   # But reduces availability
   ```

3. **Use Spot Instances** (save $3-5/month)
   ```bash
   # Add spot request to ASG
   # Can be interrupted but 90% cheaper
   ```

### Long-term Optimization

- Monitor unused resources
- Schedule automatic shutdowns during off-hours
- Use Auto Scaling based on metrics
- Implement tagging for cost allocation
- Review and optimize instance types monthly

## Next Steps

After successful deployment:

### Phase 2: Configuration Management (Week 1-2)
- Create Ansible playbooks
- Configure Nginx web server
- Deploy Node.js application
- Set up monitoring agents

### Phase 3: Containerization (Week 2) - **IN PROGRESS**
- [x] Build Docker images (`docker build`)
- [x] Create ECR Repositories (via Terraform)
- [ ] Push to Amazon ECR (`docker push`)
- [ ] Deploy to EC2 (via User Data)

#### Docker Deployment Steps:
1. **Login to ECR**:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   ```
2. **Build & Tag**:
   ```bash
   docker build -t afrimart-backend ./backend
   docker tag afrimart-backend:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/afrimart-backend:latest
   
   docker build -t afrimart-frontend ./frontend
   docker tag afrimart-frontend:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/afrimart-frontend:latest
   ```
3. **Push**:
   ```bash
   docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/afrimart-backend:latest
   docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/afrimart-frontend:latest
   ```

### Phase 4: CI/CD Pipeline (Week 2-3)
- Install Jenkins
- Create Jenkinsfile
- Set up GitHub webhook integration

### Phase 5: Kubernetes (Week 3)
- Create EKS cluster (optional)
- Deploy applications with Helm charts

### Phase 6: Monitoring (Week 3-4)
- Deploy Prometheus
- Create Grafana dashboards
- Set up alerting

### Phase 7: Security (Week 4)
- Implement secrets management
- Add SSL/TLS certificates
- Create backup procedures

## Support & Documentation

- **Terraform README**: See `terraform/README.md` (14KB comprehensive guide)
- **Quick Start**: See `terraform/QUICKSTART.md` (quick reference)
- **Checklist**: See `terraform/CHECKLIST.md` (deployment checklist)
- **AWS Documentation**: https://docs.aws.amazon.com/
- **Terraform Docs**: https://www.terraform.io/docs/

## Emergency Procedures

### If Something Goes Wrong

```bash
# 1. Check Terraform state
terraform state list
terraform state show <resource>

# 2. Verify AWS resources
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

# 3. View Terraform logs
export TF_LOG=DEBUG
terraform plan

# 4. Refresh state
terraform refresh

# 5. If state is corrupted, restore backup
terraform state pull > state-backup.json
# Edit and then:
terraform state push state-backup.json
```

### Complete Rollback

```bash
# If everything needs to be destroyed
terraform destroy

# Verify all resources deleted in AWS Console
aws ec2 describe-instances
aws rds describe-db-instances
aws elasticache describe-cache-clusters
```

---

**Status**: Ready for deployment ✅  
**Last Updated**: 2024-02-12  
**Expected Cost**: ~$53/month  
**Budget Limit**: $50/month  
**Estimated Duration**: 10-15 minutes
