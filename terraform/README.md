# Terraform Infrastructure for AfriMart E-Commerce Platform

This directory contains the Infrastructure as Code (IaC) for the AfriMart e-commerce platform on AWS, following the DevOps project requirements outlined in STUDENT_ASSIGNMENT.md.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS VPC (172.16.0.0/16)                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Internet Gateway & NAT Gateway             │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ▲                                  │
│                           │                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │   Classic Load Balancer (HTTP/HTTPS)                 │  │
│  │   Public Subnets: 172.16.101.0/24, 172.16.102.0/24  │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │   Auto Scaling Group (EC2 Instances)                 │  │
│  │   Private Subnets: 172.16.3.0/24, 172.16.4.0/24     │  │
│  │   - Instance Type: t3.micro (cost optimized)         │  │
│  │   - Min: 1, Desired: 2, Max: 4 instances             │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Backend Services (Private)                 │  │
│  │  ┌────────────┐    ┌──────────────┐                │  │
│  │  │ RDS Multi- │    │ ElastiCache  │                │  │
│  │  │ AZ Postgres│    │ Redis        │                │  │
│  │  │ db.t3.micro│    │ cache.t3.micro│               │  │
│  │  └────────────┘    └──────────────┘                │  │
│  └──────────────────────────────────────────────────────┘  │
│           ▼                                ▼                 │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │  S3 Bucket       │              │  Security Groups │    │
│  │  (Uploads)       │              │  - ALB SG        │    │
│  └──────────────────┘              │  - Web SG        │    │
│                                    │  - DB SG         │    │
│                                    │  - Cache SG      │    │
│                                    └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
terraform/
├── main.tf                    # Main module definitions
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── provider.tf                # AWS provider configuration
├── backend.tf                 # Remote state backend configuration
├── terraform.tfvars           # Terraform variables (SENSITIVE - .gitignored)
├── terraform.tfvars.example   # Example variables file
├── README.md                  # This file
│
└── modules/
    ├── vpc/
    │   ├── main.tf           # VPC, subnets, IGW, NAT Gateway, route tables
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security/
    │   ├── main.tf           # Security groups (ALB, Web, DB, Cache)
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── database/
    │   ├── main.tf           # RDS PostgreSQL, ElastiCache Redis
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── storage/
    │   ├── main.tf           # S3 bucket for uploads
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── loadbalancer/
    │   ├── main.tf           # Classic Load Balancer
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── compute/
        ├── main.tf           # EC2 Launch Template, Auto Scaling Group
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

1. **AWS Account**: Active AWS account with appropriate permissions
2. **Terraform**: v1.0 or higher
   ```bash
   terraform version
   ```
3. **AWS CLI**: Configured with credentials
   ```bash
   aws configure
   ```
4. **Git**: For version control

### AWS Permissions Required

Minimum IAM permissions needed:
- EC2 (VPC, Subnets, Security Groups, Auto Scaling, Launch Templates)
- RDS (Database instances)
- ElastiCache (Redis clusters)
- S3 (Bucket creation)
- ELB (Classic Load Balancer)
- IAM (Roles, Instance Profiles)

## Getting Started

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
region       = "us-east-1"
project_name = "afrimart"
db_username  = "afrimart"
db_password  = "YourSecurePassword123!"
```

⚠️ **IMPORTANT**: Never commit `terraform.tfvars` to version control. It's already in `.gitignore`.

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Plan the Infrastructure

```bash
terraform plan -out=tfplan
```

Review the plan carefully. This shows:
- Resources to be created
- Changes to existing resources
- Resource dependencies

### 5. Apply the Configuration

```bash
terraform apply tfplan
```

This will create all AWS resources. Typical creation time: **5-10 minutes**

### 6. Retrieve Outputs

```bash
terraform output
```

Key outputs include:
- `application_url`: URL to access your application
- `load_balancer_dns`: DNS name of the load balancer
- `rds_endpoint`: Database connection string
- `redis_endpoint`: Redis cache endpoint

## Configuration Details

### VPC Configuration

- **VPC CIDR**: 172.16.0.0/16 (customizable)
- **Availability Zones**: us-east-1a, us-east-1b
- **Public Subnets**: 172.16.101.0/24, 172.16.102.0/24
- **Private Subnets**: 172.16.3.0/24, 172.16.4.0/24
- **NAT Gateway**: Enables internet access for private subnets

### Database Configuration

- **RDS PostgreSQL**:
  - Instance: db.t3.micro (cost-optimized)
  - Version: 14.12
  - Storage: 20 GB
  - Multi-AZ: Enabled for production resilience
  - Automated Backups: Enabled

- **ElastiCache Redis**:
  - Node Type: cache.t3.micro
  - Engine Version: 7.0
  - Number of Nodes: 1
  - Port: 6379

### Compute Configuration

- **Launch Template**:
  - AMI: Amazon Linux 2 (ami-0c7217cdde317cfec) - verify for your region
  - Instance Type: t3.micro
  - IAM Role: EC2 instance profile for AWS service access

- **Auto Scaling Group**:
  - Min Size: 1 instance
  - Desired Capacity: 2 instances
  - Max Size: 4 instances
  - Load Balancer: Connected to Classic ELB

### Load Balancer Configuration

- **Type**: Classic Load Balancer (ELB)
- **Ports**: HTTP (80)
- **Health Check**: /health endpoint
- **Cross-Zone**: Enabled
- **Connection Draining**: 400 seconds

### Security Groups

| Security Group | Inbound | Outbound |
|---|---|---|
| **ALB SG** | HTTP (80), HTTPS (443) from 0.0.0.0/0 | All traffic |
| **Web SG** | All TCP (0-65535) from ALB SG | All traffic |
| **DB SG** | PostgreSQL (5432) from Web SG | None |
| **Cache SG** | Redis (6379) from Web SG | None |

### Storage Configuration

- **S3 Bucket**: Auto-generated name with prefix "afrimart-uploads-"
- **Public Access**: Blocked (all ACLs, policies, etc.)
- **Force Destroy**: true (for development/testing)

## Managing State

### Remote State (S3 Backend)

The configuration uses S3 for remote state storage with DynamoDB locking:

```bash
# Prerequisites: Create backend resources first
# 1. S3 bucket: afrimart-terraform-state
# 2. DynamoDB table: terraform-state-lock (LockID partition key)

# Then apply backend configuration
terraform init
```

### Workspaces

Use workspaces for staging/production separation:

```bash
# Create workspaces
terraform workspace new staging
terraform workspace new production

# Switch workspace
terraform workspace select staging

# List workspaces
terraform workspace list
```

## Common Operations

### View Current Infrastructure

```bash
terraform show
```

### Refresh State

```bash
terraform refresh
```

### Destroy Infrastructure

⚠️ **WARNING**: This will delete all resources!

```bash
terraform destroy
```

### Update Infrastructure

```bash
# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Cost Estimation

Estimated monthly costs (approximate):

| Resource | Size | Monthly Cost |
|---|---|---|
| EC2 | t3.micro (2 instances) | ~$7 |
| RDS | db.t3.micro | ~$15 |
| ElastiCache | cache.t3.micro | ~$10 |
| ELB | 1 load balancer | ~$16 |
| Data Transfer | ~50 GB | ~$5 |
| **Total** | | **~$53** |

### Cost Optimization Tips

1. **Stop instances when not in use**: Use AWS Backup/Snapshots
2. **Use Spot Instances**: Can save up to 90% (add to ASG configuration)
3. **Right-size resources**: Monitor usage, scale down if needed
4. **Delete unused resources**: S3 buckets, old EBS volumes, etc.
5. **Set billing alerts**: Alert when costs exceed threshold

```bash
# Example: Add spot instances to ASG (requires code modification)
# This can reduce monthly costs by 50%+
```

## Troubleshooting

### Common Issues

#### 1. AMI ID not found
**Error**: `Error: error describing images: InvalidParameterValue...`

**Solution**: Update AMI ID for your region
```bash
# Find latest Amazon Linux 2 AMI
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name]'
```

#### 2. Insufficient capacity
**Error**: `Error: error launching instances in ASG...`

**Solution**: 
- Change instance type
- Use different availability zones
- Wait a few minutes and try again

#### 3. RDS creation timeout
**Error**: `error creating RDS instance...`

**Solution**:
- Ensure IAM permissions are correct
- Check RDS quota in your account
- Verify security group allows traffic

#### 4. Load Balancer health check failing
**Error**: `Instances in service: 0`

**Solution**:
- Verify application responds to /health endpoint
- Check security group rules
- Review application logs on EC2 instance

### Debug Commands

```bash
# Validate terraform syntax
terraform validate

# Format terraform files
terraform fmt -recursive

# Lint terraform (tfsec)
tfsec .

# Show resource details
terraform state show module.vpc.aws_vpc.main

# Show all resources
terraform state list
```

## Security Best Practices

✅ **Implemented**:
- Multi-AZ RDS for high availability
- Security groups with least privilege
- S3 bucket with blocked public access
- Private subnets for compute
- NAT Gateway for secure internet access

🔄 **Recommended Enhancements**:
- [ ] Enable RDS encryption at rest
- [ ] Enable S3 bucket versioning
- [ ] Add VPC Flow Logs
- [ ] Enable CloudTrail for audit logging
- [ ] Implement SSL/TLS certificates (ACM)
- [ ] Add AWS WAF for ALB protection
- [ ] Enable GuardDuty for threat detection

## Backup & Disaster Recovery

### RDS Backups

Automated daily backups are enabled:

```bash
# Backup retention: 7 days (default)
# Backup window: 03:00-04:00 UTC

# Manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier afrimart-db \
  --db-snapshot-identifier afrimart-backup-$(date +%Y%m%d)

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier afrimart-db-restored \
  --db-snapshot-identifier <snapshot-id>
```

### S3 Bucket Backups

Enable versioning and cross-region replication for production:

```bash
# Enable versioning
aws s3api put-bucket-versioning \
  --bucket afrimart-uploads-xxx \
  --versioning-configuration Status=Enabled
```

## Monitoring & Logging

### CloudWatch Metrics

Monitor these key metrics:

- **EC2**: CPU Utilization, Network In/Out
- **RDS**: CPU Utilization, Database Connections
- **ElastiCache**: CPU Utilization, Evictions
- **ELB**: Request Count, Latency

```bash
# View EC2 metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 300 \
  --statistics Average
```

### Application Health Check

Ensure your application responds to `/health`:

```bash
# Test health endpoint
curl -v http://<load-balancer-dns>/health
```

Expected response: HTTP 200 OK

## Maintenance

### Update Configuration

To update infrastructure:

```bash
# Edit variables or module code
# Then plan and apply changes
terraform plan
terraform apply
```

### Upgrade Terraform

```bash
# Check for new versions
terraform version

# Upgrade to latest version
# Download from https://www.terraform.io/downloads

# After upgrade, reinitialize
terraform init -upgrade
```

### Review State

Regularly review and clean up state:

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.example

# Remove resource from state
terraform state rm aws_instance.example
```

## Documentation & References

### Related Files
- `STUDENT_ASSIGNMENT.md`: Complete project requirements
- `PROJECT_GUIDE.md`: Additional project guidance
- `QUICKSTART.md`: Quick setup instructions

### Useful Links
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [Cost Optimization for AWS](https://aws.amazon.com/architecture/cost-optimization/)

## Next Steps

After Terraform infrastructure is deployed:

1. **Phase 2**: Configure with Ansible playbooks
2. **Phase 3**: Build and push Docker images to ECR
3. **Phase 4**: Set up CI/CD pipeline with Jenkins
4. **Phase 5**: Deploy to Kubernetes/EKS (optional)

## Support & Questions

For issues or questions:
- Check troubleshooting section above
- Review AWS documentation
- Contact instructor: john.prexy@bloomy360.com
- Slack: #devops-project

## Important Notes

⚠️ **Production Considerations**:
- This setup uses t3.micro for cost optimization
- For production, consider upgrading instance types
- Enable RDS encryption and backups
- Implement automated patching
- Set up proper monitoring and alerting
- Implement disaster recovery procedures

💾 **State File Management**:
- Never commit `.tfstate` or `terraform.tfvars` to Git
- Always use remote state for team collaboration
- Enable state locking with DynamoDB
- Regularly backup state files

🔐 **Security Reminders**:
- Rotate database passwords regularly
- Use AWS Secrets Manager for sensitive data
- Enable MFA for AWS console access
- Regularly audit IAM permissions
- Keep Terraform and provider plugins updated

---

**Last Updated**: February 2024  
**Terraform Version**: v1.0+  
**AWS Region**: us-east-1 (customizable)
