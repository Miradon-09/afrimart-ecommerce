# Phase 2 Implementation Guide - Ansible Configuration Management

## Overview

This guide provides step-by-step instructions to deploy and configure the AfriMart infrastructure using Ansible.

**Duration:** Week 1-2  
**Evaluation Criteria:**
- Idempotency of playbooks (30%)
- Error handling (20%)
- Security configurations (30%)
- Documentation (20%)

---

## Prerequisites

### 1. Install Ansible

```bash
pip install -r ansible/requirements.txt
# Or manually:
pip install ansible boto3 botocore
```

### 2. Configure AWS Access

```bash
# Ensure AWS credentials are configured
aws configure

# Verify access
aws ec2 describe-instances --region us-east-1
```

### 3. Setup SSH Keys

```bash
# Generate key for EC2 access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/afrimart-key -N ""

# Add to SSH agent
ssh-add ~/.ssh/afrimart-key

# Or configure in ansible.cfg:
# private_key_file = ~/.ssh/afrimart-key
```

---

## Step 1: Prepare Inventory

### Option A: Dynamic Inventory (Recommended)

Dynamic inventory automatically discovers AWS EC2 instances.

```bash
# Install AWS EC2 plugin
ansible-galaxy collection install amazon.aws

# Test dynamic inventory
ansible-inventory -i ansible/inventory/aws_ec2.yml --list
```

### Option B: Static Inventory

Edit `ansible/inventory/staging` or `ansible/inventory/production` with your instance IPs:

```ini
[webservers]
web1 ansible_host=10.0.1.10
web2 ansible_host=10.0.1.11

[appservers]
app1 ansible_host=10.0.2.10

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/afrimart-key
```

---

## Step 2: Test Connectivity

```bash
# Test SSH connection to all hosts
ansible all -i ansible/inventory/aws_ec2.yml -m ping

# If using static inventory
ansible all -i ansible/inventory/staging -m ping

# Troubleshoot connection issues
ansible all -i ansible/inventory/aws_ec2.yml -m ping -vvv
```

---

## Step 3: Review Variables

### Global Variables

Edit `ansible/group_vars/all.yml`:
- Application user
- Package manager settings
- Logging configuration

### Group-Specific Variables

- `ansible/group_vars/webservers.yml` - Nginx settings
- `ansible/group_vars/appservers.yml` - Node.js settings
- `ansible/group_vars/databases.yml` - Database settings

### Host-Specific Variables (Optional)

Create `ansible/host_vars/hostname.yml` for specific host overrides.

---

## Step 4: Run Individual Playbooks

Test each playbook before running the full site playbook.

### Common Configuration

```bash
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  --tags "common"
```

### Web Servers (Nginx)

```bash
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  --tags "nginx" \
  --limit webservers
```

### Application Servers (Node.js)

```bash
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  --tags "nodejs" \
  --limit appservers
```

### Security Hardening

```bash
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  --tags "security"
```

### Monitoring Setup

```bash
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  --tags "monitoring"
```

---

## Step 5: Run Full Playbook

```bash
# Dry-run first (see what would change)
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  --check

# Run with verbose output
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  -v

# Run with maximum verbosity (for debugging)
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  -vvv

# Save output to file
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/aws_ec2.yml \
  > deployment.log 2>&1
```

---

## Evaluation Criteria

### 1. Idempotency (30%)

All playbooks must be idempotent - running them multiple times produces the same result.

**Test:**
```bash
# Run playbook twice - second run should show no changes
ansible-playbook ansible/playbooks/site.yml -i inventory/aws_ec2.yml
ansible-playbook ansible/playbooks/site.yml -i inventory/aws_ec2.yml

# Check for: "0 changed" in second run
```

**How it's implemented:**
- Use state: present/absent instead of shell commands
- Use changed_when to control change reporting
- Use handlers for service restarts

### 2. Error Handling (20%)

Playbooks must handle errors gracefully.

**Examples:**
- Failed tasks should notify or trigger handlers
- Non-critical failures can use `ignore_errors: yes`
- Block/rescue/always for error handling

**Test:**
```bash
# Run with a host down
# Playbook should fail gracefully with clear error message
```

### 3. Security Configurations (30%)

Implement security best practices throughout.

**Implemented:**
- SSH hardening (no password auth, no root login)
- Firewall configuration (only open necessary ports)
- fail2ban setup (brute force protection)
- Non-root service execution
- No hardcoded credentials

**Verify:**
```bash
# Check SSH configuration
ansible all -i inventory/aws_ec2.yml -m shell -a "cat /etc/ssh/sshd_config | grep PermitRootLogin"

# Check firewall rules
ansible all -i inventory/aws_ec2.yml -m shell -a "sudo firewall-cmd --list-all"

# Check fail2ban
ansible all -i inventory/aws_ec2.yml -m shell -a "sudo systemctl status fail2ban"
```

### 4. Documentation (20%)

Comprehensive documentation for all playbooks and roles.

**Included:**
- README.md with overview
- PHASE2_GUIDE.md (this file) with step-by-step
- Inline comments in playbooks
- Role descriptions

---

## Roles Overview

### common
Runs on all hosts.

**Tasks:**
- Update package cache
- Install common packages
- Create application user
- Create directories
- Set timezone

**Tags:** `common`

### nginx  
Web server and reverse proxy.

**Tasks:**
- Install Nginx
- Deploy reverse proxy config
- Start and enable service

**Tags:** `nginx`

### nodejs
Application server runtime.

**Tasks:**
- Install Node.js
- Install PM2
- Create .env file
- Create systemd service
- Start application

**Tags:** `nodejs`

### security
Security hardening.

**Tasks:**
- Install security packages
- Configure firewall
- Harden SSH
- Setup fail2ban

**Tags:** `security`

### monitoring
Monitoring and observability.

**Tasks:**
- Install node_exporter
- Create prometheus user
- Setup systemd service
- Verify metrics

**Tags:** `monitoring`

---

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH directly
ssh -i ~/.ssh/afrimart-key ec2-user@<instance-ip>

# Check SSH key permissions
ls -la ~/.ssh/afrimart-key
# Should be: -rw------- (600)

# Test with Ansible
ansible all -i inventory/aws_ec2.yml -m ping -vvv
```

### Playbook Syntax Errors

```bash
# Check syntax
ansible-playbook ansible/playbooks/site.yml --syntax-check

# Validate variables
ansible-playbook ansible/playbooks/site.yml --list-vars

# List tasks
ansible-playbook ansible/playbooks/site.yml --list-tasks
```

### Hosts Not Found

```bash
# List discovered hosts
ansible-inventory -i inventory/aws_ec2.yml --list

# Check AWS filters in inventory/aws_ec2.yml
# Ensure instances are tagged: Name=afrimart-*
```

### Task Failures

```bash
# Run with increased verbosity
ansible-playbook ansible/playbooks/site.yml -vvvv

# Run specific task with debugging
ansible-playbook ansible/playbooks/site.yml \
  --tasks "task name" \
  -vvv

# Check logs on target host
ssh -i ~/.ssh/afrimart-key ec2-user@<instance-ip>
sudo tail -f /var/log/messages
```

---

## Commands Reference

### Playbook Execution

```bash
# Run all playbooks
ansible-playbook playbooks/site.yml

# Run specific playbook
ansible-playbook playbooks/webservers.yml

# Run with tags
ansible-playbook playbooks/site.yml --tags "nginx,nodejs"

# Skip tags
ansible-playbook playbooks/site.yml --skip-tags "monitoring"

# Limit to specific hosts
ansible-playbook playbooks/site.yml --limit "webservers"

# Dry-run
ansible-playbook playbooks/site.yml --check

# Extra variables
ansible-playbook playbooks/site.yml -e "environment=production"
```

### Ad-Hoc Commands

```bash
# Ping hosts
ansible all -m ping

# Get system info
ansible all -m setup

# Run command
ansible all -m shell -a "uptime"

# Copy file
ansible all -m copy -a "src=file dest=/tmp/"

# Install package
ansible all -m yum -a "name=nginx"

# Check service status
ansible all -m service -a "name=nginx state=started"
```

---

## Verification Checklist

After running playbooks, verify:

- [ ] All hosts are reachable (`ansible all -m ping`)
- [ ] Common packages installed on all hosts
- [ ] Nginx is running and configured (`curl localhost`)
- [ ] Node.js application is running
- [ ] Security policies are enforced
- [ ] Monitoring agent is collecting metrics
- [ ] Playbooks are idempotent (run twice, no changes)
- [ ] Application logs are being collected
- [ ] Services start on boot (`sudo systemctl status`)

---

## Performance Optimization

### Parallel Execution

Ansible runs tasks sequentially by default. Speed up execution:

```bash
# Set forks in ansible.cfg
[defaults]
forks = 10

# Or via command line
ansible-playbook playbooks/site.yml -f 10
```

### Facts Caching

Facts are cached to speed up subsequent runs:

```bash
# In ansible.cfg (already configured)
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
```

---

## Next Steps (Phase 3)

After Phase 2 is complete:

1. **Containerization (Phase 3)**
   - Build Docker images
   - Push to ECR
   - Create docker-compose

2. **CI/CD Pipeline (Phase 4)**
   - Setup Jenkins
   - Create Jenkinsfile
   - GitHub webhook integration

3. **Kubernetes (Phase 5)**
   - Create EKS cluster
   - Deploy with Helm

---

## Support

**Ansible Documentation:** https://docs.ansible.com

**Common Issues:**

| Issue | Solution |
|-------|----------|
| Hosts not found | Check inventory, verify tags, use `ansible-inventory --list` |
| SSH errors | Verify key permissions (600), check security groups |
| Task failures | Use `-vvv`, check host logs, verify variables |
| Idempotency issues | Use state instead of shell, add changed_when |
| Permission errors | Ensure SSH user has sudo privileges |

---

## Summary

**Phase 2 Deliverables:**
- ✅ 5 Ansible roles (common, nginx, nodejs, security, monitoring)
- ✅ Main playbook orchestrating all roles
- ✅ Dynamic inventory using AWS EC2 plugin
- ✅ Group and host variables
- ✅ Idempotent playbooks
- ✅ Error handling
- ✅ Security best practices
- ✅ Comprehensive documentation

**Ready for deployment!** 🚀
