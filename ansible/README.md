# Ansible Configuration Management - Phase 2

This directory contains Ansible playbooks and roles to configure and deploy the AfriMart e-commerce platform.

## Quick Start

```bash
cd ansible

# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure inventory
# Edit inventory/aws_ec2.yml or inventory/staging

# 3. Test connectivity
ansible all -i inventory/aws_ec2.yml -m ping

# 4. Run main playbook
ansible-playbook playbooks/site.yml -i inventory/aws_ec2.yml

# 5. Or run specific playbooks
ansible-playbook playbooks/webservers.yml -i inventory/aws_ec2.yml
ansible-playbook playbooks/appservers.yml -i inventory/aws_ec2.yml
ansible-playbook playbooks/security.yml -i inventory/aws_ec2.yml
ansible-playbook playbooks/monitoring.yml -i inventory/aws_ec2.yml
ansible-playbook playbooks/deploy.yml -i inventory/aws_ec2.yml
```

## Directory Structure

```
ansible/
├── playbooks/
│   ├── site.yml ...................... Main playbook
│   ├── webservers.yml ................ Nginx configuration
│   ├── appservers.yml ................ Node.js deployment
│   ├── security.yml .................. Hardening
│   ├── monitoring.yml ................ Monitoring setup
│   └── deploy.yml .................... Application deployment
│
├── roles/
│   ├── common/ ....................... Common tasks
│   ├── nginx/ ........................ Web server
│   ├── nodejs/ ....................... Application runtime
│   ├── security/ ..................... Security hardening
│   └── monitoring/ ................... Monitoring
│
├── inventory/
│   ├── aws_ec2.yml ................... Dynamic inventory
│   ├── staging ....................... Static inventory
│   └── production .................... Static inventory
│
├── group_vars/
│   ├── all.yml ....................... Global variables
│   ├── webservers.yml ................ Web server variables
│   ├── appservers.yml ................ App server variables
│   └── databases.yml ................. Database variables
│
└── host_vars/
    └── (hostname-specific variables)
```

## Roles

### common
Runs on all hosts. Installs common packages and tools.
- Update package manager
- Install base tools
- Create application user
- Configure SSH

### nginx
Web server and reverse proxy.
- Install Nginx
- Configure as reverse proxy
- Manage SSL/TLS
- Health checks

### nodejs
Application server runtime.
- Install Node.js and npm
- Install PM2 process manager
- Deploy application code
- Manage environment variables

### security
Security hardening.
- Firewall configuration
- fail2ban setup
- SSH hardening
- SELinux/AppArmor
- Sudo configuration

### monitoring
Monitoring and observability.
- Install node_exporter (Prometheus metrics)
- Log rotation
- CloudWatch agent (optional)
- Log shipping

## Playbooks

### site.yml - Main Playbook
Orchestrates all roles for complete setup.

```bash
ansible-playbook playbooks/site.yml -i inventory/aws_ec2.yml
```

### webservers.yml - Web Server Setup
Configures Nginx web servers.

```bash
ansible-playbook playbooks/webservers.yml -i inventory/aws_ec2.yml
```

### appservers.yml - Application Setup
Deploys Node.js application servers.

```bash
ansible-playbook playbooks/appservers.yml -i inventory/aws_ec2.yml
```

### security.yml - Security Hardening
Implements security best practices.

```bash
ansible-playbook playbooks/security.yml -i inventory/aws_ec2.yml
```

### monitoring.yml - Monitoring Setup
Configures monitoring and observability.

```bash
ansible-playbook playbooks/monitoring.yml -i inventory/aws_ec2.yml
```

### deploy.yml - Application Deployment
Deploys and starts the application.

```bash
ansible-playbook playbooks/deploy.yml -i inventory/aws_ec2.yml
```

## Inventory

### Dynamic Inventory (Recommended)
Automatically discovers AWS EC2 instances.

```bash
ansible-playbook playbooks/site.yml -i inventory/aws_ec2.yml
```

### Static Inventory
Manual inventory configuration for staging/production.

```bash
ansible-playbook playbooks/site.yml -i inventory/staging
ansible-playbook playbooks/site.yml -i inventory/production
```

## Variables

### Global Variables (all.yml)
```yaml
ansible_user: ec2-user
app_user: afrimart
app_home: /opt/afrimart
```

### Group Variables
- webservers.yml - Nginx settings
- appservers.yml - Node.js settings
- databases.yml - Database settings

### Host Variables
Host-specific overrides in `host_vars/`

## Tags

Run specific parts of playbooks:

```bash
# Run only Nginx
ansible-playbook playbooks/site.yml --tags "nginx"

# Skip monitoring
ansible-playbook playbooks/site.yml --skip-tags "monitoring"

# Multiple tags
ansible-playbook playbooks/site.yml --tags "nginx,nodejs"
```

Available tags:
- common
- nginx
- nodejs
- security
- monitoring
- deploy

## Commands

### Basic Commands
```bash
# Ping all hosts
ansible all -i inventory/aws_ec2.yml -m ping

# Get host information
ansible all -i inventory/aws_ec2.yml -m setup

# Run a command on all hosts
ansible all -i inventory/aws_ec2.yml -m shell -a "uptime"

# Copy file to all hosts
ansible all -i inventory/aws_ec2.yml -m copy -a "src=file dest=/tmp/"
```

### Playbook Commands
```bash
# Check syntax
ansible-playbook playbooks/site.yml --syntax-check

# Dry-run (show what would change)
ansible-playbook playbooks/site.yml --check

# List tasks
ansible-playbook playbooks/site.yml --list-tasks

# List hosts
ansible-playbook playbooks/site.yml --list-hosts

# Run with verbose output
ansible-playbook playbooks/site.yml -vvv

# Run with extra variables
ansible-playbook playbooks/site.yml -e "environment=production"
```

## Troubleshooting

### SSH Connection Issues
```bash
ssh -i ~/.ssh/afrimart-key ec2-user@<instance-ip>
ansible all -i inventory/aws_ec2.yml -m ping -vvv
```

### Check Host Discovery
```bash
ansible-inventory -i inventory/aws_ec2.yml --list
```

### Playbook Syntax Check
```bash
ansible-playbook playbooks/site.yml --syntax-check
```

### Run with Maximum Verbosity
```bash
ansible-playbook playbooks/site.yml -vvvv
```

## Idempotency

All playbooks are idempotent - running them multiple times produces the same result. Key practices:

- Use `state: present/absent` instead of shell commands
- Use handlers for service restarts
- Track actual changes with `changed_when`

## Error Handling

Playbooks include error handling with:
- Block/rescue/always
- Ignore errors for non-critical tasks
- Handlers for cleanup
- Proper error messages

## Security Best Practices

1. **No Hardcoded Secrets**
   - Use Ansible Vault for secrets
   - Use AWS Secrets Manager
   - Use environment variables

2. **SSH Keys**
   - Key-based authentication only
   - Secure key storage
   - Regular key rotation

3. **Least Privilege**
   - Run services as non-root
   - Proper sudo configuration
   - Minimal required permissions

4. **Firewall**
   - Only open necessary ports
   - Use security groups
   - Host-level firewall

## Next Steps

1. **Configure Inventory**
   - Edit inventory/aws_ec2.yml or inventory/staging
   - Test connectivity

2. **Update Variables**
   - Set group_vars/all.yml
   - Configure role-specific variables

3. **Test Playbooks**
   - Run individual playbooks first
   - Use --check flag to preview changes

4. **Deploy**
   - Run full site.yml playbook
   - Monitor for errors

5. **Verify**
   - Check services are running
   - Verify application is accessible
   - Monitor logs

## Documentation

For detailed implementation:
- See PHASE2_GUIDE.md for step-by-step guide
- See each role's README for specific configuration
- Check playbook comments for usage

## Support

- Ansible Docs: https://docs.ansible.com
- Role-specific README files
- Playbook comments and task names

---

**Phase 2: Ansible Configuration Management - Ready to Deploy** ✅
