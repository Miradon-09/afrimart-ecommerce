# Phase 2 Submission Guide - Ansible Configuration Management

## Overview

This guide prepares you for the Phase 2 (Week 1-2) evaluation with your tutor. It includes grading rubric, presentation strategy, and verification checklist.

**Evaluation Date:** Week 1-2 end  
**Total Marks:** 100 points  
**Duration:** 15-20 minutes presentation

---

## Grading Rubric

### 1. Idempotency (30 points)

**What it means:** Running playbooks multiple times produces the same result - no unwanted changes on second run.

**How it's assessed:**
- Run playbook once → changes made
- Run playbook again → "0 changed" (or minimal expected changes)
- Tasks use `state: present/absent` not shell commands
- Handlers for service management

**How to demonstrate:**
```bash
# First run
ansible-playbook ansible/playbooks/site.yml -i inventory/aws_ec2.yml

# Second run - should show "0 changed"
ansible-playbook ansible/playbooks/site.yml -i inventory/aws_ec2.yml

# Show output to tutor - watch for "0 changed" in summary
```

**Marks breakdown:**
- 10 pts: All roles use state parameters
- 10 pts: No shell commands with side effects
- 10 pts: Handlers for service restarts

---

### 2. Error Handling (20 points)

**What it means:** Playbooks handle failures gracefully with clear error messages and recovery options.

**How it's assessed:**
- Graceful task failures
- Handlers notify on errors
- Meaningful error messages
- Block/rescue/always patterns

**How to demonstrate:**
```bash
# Show error handling in playbook
cat ansible/playbooks/site.yml | grep -A5 "block:"

# Show security role with rescue
cat ansible/roles/security/tasks/main.yml | grep -A10 "rescue:"
```

**Marks breakdown:**
- 7 pts: Block/rescue patterns implemented
- 7 pts: Clear error messages
- 6 pts: Recovery handlers

---

### 3. Security Configurations (30 points)

**What it means:** Production-ready security hardening across all servers.

**How it's assessed:**
- SSH hardening (no password auth, no root login)
- Firewall configuration (minimal ports)
- fail2ban for brute force protection
- No hardcoded credentials
- Non-root service execution

**How to demonstrate:**
```bash
# Show security role
cat ansible/roles/security/tasks/main.yml

# Show SSH hardening
cat ansible/roles/security/files/sshd_config

# Show firewall rules
grep firewalld ansible/roles/security/tasks/main.yml

# Show fail2ban
grep fail2ban ansible/roles/security/tasks/main.yml
```

**Marks breakdown:**
- 10 pts: SSH hardening implemented
- 10 pts: Firewall configuration
- 10 pts: fail2ban and security packages

---

### 4. Documentation (20 points)

**What it means:** Clear, comprehensive documentation for someone to use and understand your code.

**How it's assessed:**
- README.md with overview
- Step-by-step deployment guide
- Inline comments in code
- Role descriptions
- Troubleshooting guide
- Variable documentation

**How to demonstrate:**
```bash
# Show documentation files
ls -lh ansible/*.md

# Show README
cat ansible/README.md | head -50

# Show PHASE2_GUIDE.md
cat ansible/PHASE2_GUIDE.md | head -50

# Show comments in code
cat ansible/roles/nginx/tasks/main.yml | head -30
```

**Marks breakdown:**
- 5 pts: README.md (overview and quick start)
- 5 pts: PHASE2_GUIDE.md (step-by-step)
- 5 pts: Inline comments in roles
- 5 pts: Troubleshooting and variable docs

---

## 15-Minute Presentation Outline

### Opening (1 minute)

```
"Hi, I've completed Phase 2 - Ansible Configuration Management for AfriMart.
Today I'll show you:
1. The Ansible architecture
2. How idempotency works
3. Security implementations
4. Documentation
"
```

### Part 1: Architecture Overview (3 minutes)

**What to show:**
```bash
# Show directory structure
tree -L 2 ansible/

# Show roles
ls -la ansible/roles/
```

**What to say:**
"I've organized Ansible into 5 roles:
- **common**: Runs on all hosts (packages, user creation, directories)
- **nginx**: Web server reverse proxy
- **nodejs**: Application server runtime
- **security**: Hardening (SSH, firewall, fail2ban)
- **monitoring**: node_exporter for metrics

This modular approach allows:
- Reusing roles across environments
- Testing individual roles
- Clear separation of concerns
- Easy maintenance
"

### Part 2: Inventory Management (2 minutes)

**What to show:**
```bash
# Show dynamic inventory
cat ansible/inventory/aws_ec2.yml

# Show static inventory
cat ansible/inventory/staging
```

**What to say:**
"I've implemented two inventory methods:

1. **Dynamic Inventory** (aws_ec2.yml):
   - Automatically discovers EC2 instances
   - Filters instances by tags (Name=afrimart-*)
   - Groups by type (webservers, appservers, databases)
   - Great for automation - no manual updates needed

2. **Static Inventory** (staging, production):
   - Fallback for environments without dynamic discovery
   - Useful for testing locally
   - Clear host grouping

This gives flexibility for different deployment scenarios.
"

### Part 3: Idempotency (3 minutes)

**What to show:**
```bash
# First run
ansible-playbook ansible/playbooks/site.yml --check -i inventory/aws_ec2.yml
# Show: "X changed"

# Second run
ansible-playbook ansible/playbooks/site.yml --check -i inventory/aws_ec2.yml
# Show: "0 changed"
```

**What to say:**
"Idempotency is critical for production:

Every task uses `state: present/absent` instead of shell commands:
- `yum: name=nginx state=present` ✅ (idempotent)
- `shell: yum install nginx` ❌ (not idempotent)

When you run the playbook multiple times:
- First run: Creates/configures resources (X changed)
- Second run: No changes (0 changed)

This is essential for:
- Re-running playbooks safely
- Drift detection
- Maintenance and updates
- Automated remediation
"

### Part 4: Security (4 minutes)

**What to show:**
```bash
# Show security role tasks
cat ansible/roles/security/tasks/main.yml

# Show SSH hardening
cat ansible/roles/security/files/sshd_config | grep -A5 "PermitRootLogin\|PasswordAuthentication"

# Show firewall configuration
grep -A10 "firewalld" ansible/roles/security/tasks/main.yml

# Show fail2ban
grep -A5 "fail2ban" ansible/roles/security/tasks/main.yml
```

**What to say:**
"I've implemented comprehensive security hardening:

1. **SSH Hardening**:
   - Disabled root login (PermitRootLogin no)
   - Disabled password authentication (PasswordAuthentication no)
   - Only key-based auth
   - Protects against brute force attacks

2. **Firewall Configuration**:
   - Opens only necessary ports:
     - 22: SSH (management)
     - 80: HTTP (application)
     - 443: HTTPS (future)
     - 3000: Node.js (internal)
   - All other traffic blocked

3. **fail2ban**:
   - Automatic brute force protection
   - Bans IPs after failed attempts
   - Prevents unauthorized access

4. **No Hardcoded Credentials**:
   - All secrets in variables
   - Never committed to git
   - Can be rotated via Vault in future
"

### Part 5: Documentation & Conclusion (2 minutes)

**What to show:**
```bash
# Show documentation
ls -lh ansible/*.md

# Show README
head -30 ansible/README.md

# Show quick start
head -30 ansible/PHASE2_GUIDE.md
```

**What to say:**
"I've provided comprehensive documentation:

- **README.md**: Overview, architecture, quick start
- **PHASE2_GUIDE.md**: Step-by-step deployment guide
- **Inline comments**: In every role explaining what tasks do
- **Troubleshooting**: Common issues and solutions

This allows anyone to:
- Understand the architecture
- Deploy independently
- Troubleshoot issues
- Maintain and extend

I'm ready to answer any questions!"

---

## Submission Files Checklist

Before meeting with tutor, ensure you have:

### Core Files

- [x] `ansible/README.md` - Overview
- [x] `ansible/PHASE2_GUIDE.md` - Implementation guide
- [x] `ansible/PHASE2_SUBMISSION.md` - This submission guide
- [x] `ansible/requirements.txt` - Dependencies
- [x] `ansible/ansible.cfg` - Configuration

### Inventory Files

- [x] `ansible/inventory/aws_ec2.yml` - Dynamic inventory
- [x] `ansible/inventory/staging` - Static staging
- [x] `ansible/inventory/production` - Static production

### Playbooks

- [x] `ansible/playbooks/site.yml` - Main orchestration

### Roles (5 roles × 3 files each)

**common:**
- [x] `ansible/roles/common/tasks/main.yml`
- [x] `ansible/roles/common/handlers/main.yml`
- [x] `ansible/roles/common/vars/main.yml`

**nginx:**
- [x] `ansible/roles/nginx/tasks/main.yml`
- [x] `ansible/roles/nginx/handlers/main.yml`
- [x] `ansible/roles/nginx/templates/nginx.conf.j2`

**nodejs:**
- [x] `ansible/roles/nodejs/tasks/main.yml`
- [x] `ansible/roles/nodejs/handlers/main.yml`
- [x] `ansible/roles/nodejs/templates/app.service.j2`

**security:**
- [x] `ansible/roles/security/tasks/main.yml`
- [x] `ansible/roles/security/handlers/main.yml`
- [x] `ansible/roles/security/files/sshd_config`

**monitoring:**
- [x] `ansible/roles/monitoring/tasks/main.yml`
- [x] `ansible/roles/monitoring/handlers/main.yml`

### Variables

- [x] `ansible/group_vars/all.yml`
- [x] `ansible/group_vars/webservers.yml`
- [x] `ansible/group_vars/appservers.yml`
- [x] `ansible/group_vars/databases.yml`

---

## Expected Marks

### Conservative Estimate (85-90/100)

```
Idempotency:        27/30 (-3 for potential edge cases)
Error Handling:     18/20 (-2 for minor improvements)
Security:          28/30 (-2 for additional hardening)
Documentation:     18/20 (-2 for more examples)
────────────────────────
TOTAL:            91/100
```

### Optimistic Estimate (95-100/100)

```
Idempotency:        30/30 (all tasks idempotent)
Error Handling:     20/20 (comprehensive blocks/rescue)
Security:          30/30 (all best practices)
Documentation:     20/20 (complete guides)
────────────────────────
TOTAL:            100/100
```

---

## Verification Checklist

Run these before your tutor meeting:

### Syntax Validation

```bash
# Check playbook syntax
ansible-playbook ansible/playbooks/site.yml --syntax-check

# Validate YAML
python3 -m yaml ansible/playbooks/site.yml
```

### Connectivity Test

```bash
# Test Ansible connectivity (if infrastructure exists)
ansible all -i ansible/inventory/aws_ec2.yml -m ping
```

### Idempotency Test

```bash
# Run with --check twice
ansible-playbook ansible/playbooks/site.yml --check
ansible-playbook ansible/playbooks/site.yml --check
# Second should show: "0 changed"
```

### Documentation Review

```bash
# Verify all docs exist
ls -lh ansible/*.md

# Check for typos
grep -r "TODO\|FIXME\|XXX" ansible/

# Verify comments in roles
grep -c "^#" ansible/roles/*/tasks/main.yml
```

### File Count Verification

```bash
# Count files
find ansible -type f | wc -l
# Should be ~40+ files

# List all files
find ansible -type f | sort
```

---

## Common Questions from Tutors

**Q: Why use dynamic inventory instead of static?**

A: Dynamic inventory automatically discovers AWS instances, eliminating manual updates. It's production-grade and scales better. We also provide static inventory as fallback for local testing.

---

**Q: How do you ensure idempotency?**

A: Every task uses `state` parameters (present/absent/started/stopped) instead of shell commands. This ensures:
- Running multiple times produces same result
- Safe for automation and CI/CD
- Detects and prevents drift

---

**Q: Why these specific security measures?**

A: I implemented:
- SSH hardening: Standard production practice
- Firewall: Principle of least privilege
- fail2ban: Brute force protection
- Variables for secrets: Never hardcode credentials

These align with AWS and industry best practices.

---

**Q: Can roles be reused in other projects?**

A: Yes! They're designed to be independent:
- Each role is self-contained
- All variables configurable via group_vars
- No hard dependencies between roles
- Can be copied to other projects

---

**Q: What about database backups?**

A: Out of scope for Phase 2 (configuration management). Phase 2 focuses on:
- Infrastructure provisioning (Ansible)
- Configuration management
- Security hardening
- Monitoring setup

Database backups would be in Phase 5 (advanced operations).

---

## Pro Tips for Meeting

### Before Meeting

1. **Test everything** - Run playbook syntax check and idempotency test
2. **Prepare terminals** - Have 2-3 terminals ready (one for playbook, one for docs, one for questions)
3. **Know your code** - Be able to explain each role quickly
4. **Have backups** - Screenshot console output in case of connectivity issues

### During Meeting

1. **Start with overview** - Show architecture diagram (tree -L 2 ansible/)
2. **Demo idempotency** - This is 30% of grade - make it clear!
3. **Discuss security** - Show actual implementations, not just theory
4. **Answer questions** - Be ready to explain why you chose certain approaches
5. **Stay calm** - Most tutors want to see you understand the technology

### Talking Points

- "Idempotency means..."
- "This role is independent because..."
- "Security is important because..."
- "Variables make it reusable because..."
- "Dynamic inventory helps because..."

---

## Post-Meeting Checklist

After your Phase 2 evaluation:

- [ ] Get feedback from tutor
- [ ] Document any suggested improvements
- [ ] Save marks/feedback
- [ ] Plan Phase 3 (Docker containerization)
- [ ] Update project timeline

---

## Next Phase (Phase 3 - Docker)

After Phase 2 is complete, Phase 3 involves:

1. Creating Dockerfile for Node.js app
2. Creating Dockerfile for Nginx
3. Building Docker images
4. Pushing to ECR (Elastic Container Registry)
5. Creating docker-compose.yml
6. Testing locally with Docker

---

## Summary

**What you have:**
- ✅ Production-ready Ansible playbooks
- ✅ 5 independent, reusable roles
- ✅ Dynamic inventory system
- ✅ Comprehensive security hardening
- ✅ Complete documentation

**What tutors will evaluate:**
- Idempotency (30%): Playbooks safe to run repeatedly
- Error Handling (20%): Graceful failure management
- Security (30%): Production-grade hardening
- Documentation (20%): Clear, comprehensive guides

**Expected outcome:**
- 85-100/100 marks
- Ready for Phase 3
- Production-ready infrastructure automation

---

**Good luck with your Phase 2 presentation!** 🚀

For questions, refer to:
- `ansible/PHASE2_GUIDE.md` - Step-by-step guide
- `ansible/README.md` - Overview and troubleshooting
- Individual role files for implementation details
