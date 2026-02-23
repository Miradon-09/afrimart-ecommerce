# AfriMart Terraform Quick Start Guide

## Quick Setup (5 minutes)

```bash
# 1. Navigate to terraform directory
cd terraform

# 2. Initialize Terraform
terraform init

# 3. Create terraform.tfvars file
cat > terraform.tfvars << EOF
region       = "us-east-1"
project_name = "afrimart"
db_username  = "afrimart"
db_password  = "Change@This123!"
EOF

# 4. Plan infrastructure
terraform plan -out=tfplan

# 5. Apply infrastructure
terraform apply tfplan

# 6. Get outputs
terraform output
```

## Essential Commands

```bash
# Show infrastructure plan without applying
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure (WARNING: Data loss!)
terraform destroy

# View current state
terraform show

# List all resources
terraform state list

# View specific resource
terraform state show aws_vpc.main

# Refresh state from AWS
terraform refresh

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Get outputs
terraform output
terraform output application_url
```

## Environment Variables

```bash
# Set AWS region
export AWS_REGION=us-east-1

# Set AWS profile (if not using default)
export AWS_PROFILE=myprofile
```

## Key Resources Created

| Resource | Name | Cost (Monthly) |
|----------|------|---|
| VPC | afrimart-vpc | Free |
| Public Subnets (2x) | afrimart-public-1/2 | Free |
| Private Subnets (2x) | afrimart-private-1/2 | Free |
| Internet Gateway | afrimart-igw | Free |
| NAT Gateway | afrimart-nat | ~$32 |
| Classic Load Balancer | afrimart-clb | ~$16 |
| EC2 Instances (2x) | afrimart-instance (ASG) | ~$7 |
| RDS PostgreSQL | afrimart-db | ~$15 |
| ElastiCache Redis | afrimart-redis | ~$10 |
| S3 Bucket | afrimart-uploads-* | ~$2 |
| Security Groups (4x) | afrimart-*-sg | Free |
| **Total** | | **~$82** |

Note: To stay within $50 budget, consider:
- Reducing ASG from 2 to 1 instance
- Using Spot instances (add ~$2 config)
- Removing NAT Gateway and using VPC endpoints

## Terraform Variables

Edit `terraform.tfvars` to customize:

```hcl
region              = "us-east-1"           # AWS region
project_name        = "afrimart"            # Project name prefix
vpc_cidr            = "172.16.0.0/16"      # VPC CIDR block
availability_zones  = ["us-east-1a", "us-east-1b"]
public_subnets      = ["172.16.101.0/24", "172.16.102.0/24"]
private_subnets     = ["172.16.3.0/24", "172.16.4.0/24"]
db_username         = "afrimart"            # RDS username
db_password         = "YourPassword123!"    # RDS password (CHANGE THIS!)
```

## Module Structure

```
modules/
├── vpc/              → VPC, Subnets, IGW, NAT, Route Tables
├── security/         → Security Groups
├── database/         → RDS PostgreSQL, ElastiCache Redis
├── storage/          → S3 Bucket
├── loadbalancer/     → Classic Load Balancer
└── compute/          → EC2, Auto Scaling Group
```

## Troubleshooting

### Issue: "Error: InvalidParameterValue"
**Solution**: Update AMI ID for your region
```bash
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text
```

### Issue: "Error: error creating RDS instance"
**Solution**: Check RDS quotas in your AWS account

### Issue: "terraform init fails with backend error"
**Solution**: Comment out `backend.tf` or create S3 bucket first:
```bash
# Temporarily disable backend
mv terraform/backend.tf terraform/backend.tf.bak
terraform init
# After initial setup, restore backend
mv terraform/backend.tf.bak terraform/backend.tf
```

### Issue: Application not responding to health checks
**Solution**: Ensure application listens on port 80 and responds to `/health`

## Monitoring After Deployment

```bash
# View EC2 instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=afrimart-*"

# View RDS database
aws rds describe-db-instances --db-instance-identifier afrimart-db

# View load balancer
aws elbv2 describe-load-balancers --names afrimart-clb

# Check ASG status
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names afrimart-asg

# View application logs
ssh -i key.pem ec2-user@<instance-ip>
tail -f /var/log/messages
```

## Cost Optimization

### Option 1: Minimum Cost Setup (~$25/month)
```hcl
# In compute module
desired_capacity = 1    # Reduce from 2
max_size        = 2     # Reduce from 4
```

### Option 2: Use Spot Instances (~$15/month savings)
```bash
# Add to ASG configuration (requires module edit)
# spot_price = "0.05"
```

### Option 3: Stop Resources During Downtime
```bash
# Stop instances (keep EBS volumes)
aws ec2 stop-instances --instance-ids i-0123456789abcdef0

# Start instances later
aws ec2 start-instances --instance-ids i-0123456789abcdef0
```

## Useful AWS CLI Commands

```bash
# Get application URL
terraform output application_url

# Get database endpoint
terraform output rds_endpoint

# Get Redis endpoint  
terraform output redis_endpoint

# Check AWS account
aws sts get-caller-identity

# List all resources created
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=afrimart-*"

# Monitor costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## Best Practices

✅ **Do**:
- Always plan before applying: `terraform plan`
- Use remote state for collaboration
- Tag all resources
- Keep secrets out of code
- Test in staging first
- Review diffs carefully

❌ **Don't**:
- Commit `terraform.tfvars` to Git
- Manually modify AWS resources (use Terraform instead)
- Use production values during testing
- Leave resources running when not needed
- Share AWS credentials

## Next Steps

1. **Setup Ansible**: Configure servers with playbooks
2. **Build Docker images**: Create application containers
3. **Setup ECR**: Push images to Amazon ECR
4. **Configure CI/CD**: Set up Jenkins pipeline
5. **Deploy to Kubernetes**: Use EKS for container orchestration

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS Free Tier Limits](https://aws.amazon.com/free/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)

---

For detailed information, see `README.md` in this directory.
