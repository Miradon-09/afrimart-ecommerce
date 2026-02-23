# AfriMart Ansible Setup Instructions

## Quick Start (5 minutes)

### 1. Create Python Virtual Environment

```bash
cd /home/jayps
python3 -m venv ansible-env
source ansible-env/bin/activate
```

### 2. Install Dependencies

```bash
pip install ansible boto3 botocore
```

### 3. Navigate to Ansible Directory

```bash
cd /home/jayps/afrimart-ecommerce/ansible
```

### 4. Verify Syntax

```bash
ansible-playbook playbooks/site.yml --syntax-check -i inventory/staging
# Output: playbook: playbooks/site.yml ✅
```

### 5. Check Inventory

```bash
ansible-inventory -i inventory/staging --list
# Shows all hosts grouped by type ✅
```

---

## Virtual Environment Activation

### Each Session - Activate Environment

```bash
source /home/jayps/ansible-env/bin/activate
```

### Deactivate

```bash
deactivate
```

---

## Common Commands

### Check Syntax

```bash
cd /home/jayps/afrimart-ecommerce/ansible
ansible-playbook playbooks/site.yml --syntax-check -i inventory/staging
```

### List Inventory

```bash
ansible-inventory -i inventory/staging --list
```

### Dry-Run Playbook

```bash
ansible-playbook playbooks/site.yml -i inventory/staging --check
```

### Run with Specific Tags

```bash
ansible-playbook playbooks/site.yml -i inventory/staging --tags "common"
```

### Run with Verbose Output

```bash
ansible-playbook playbooks/site.yml -i inventory/staging -v
```

---

## Inventory Options

### Static Inventory (Recommended for Testing)

```bash
ansible-inventory -i inventory/staging --list
ansible-inventory -i inventory/production --list
```

### Dynamic Inventory (When AWS Credentials Configured)

```bash
ansible-inventory -i inventory/aws_ec2.yml --list
```

---

## Environment Variables (Optional)

Set custom locations:

```bash
export ANSIBLE_CONFIG=/home/jayps/afrimart-ecommerce/ansible/ansible.cfg
export ANSIBLE_INVENTORY=/home/jayps/afrimart-ecommerce/ansible/inventory/staging
```

---

## Troubleshooting

### Issue: "No inventory was parsed"

**Solution:** Make sure you're in the ansible directory:
```bash
cd /home/jayps/afrimart-ecommerce/ansible
ansible-playbook playbooks/site.yml -i inventory/staging --syntax-check
```

### Issue: "Unable to parse inventory source"

**Solution:** Use INI format (no `---` header):
```bash
# ❌ Wrong - has YAML header
---
[webservers]
host1 ansible_host=10.0.0.1

# ✅ Right - INI format only
[webservers]
host1 ansible_host=10.0.0.1
```

### Issue: "roles not found"

**Solution:** Run from ansible directory with relative paths:
```bash
cd /home/jayps/afrimart-ecommerce/ansible
ansible-playbook playbooks/site.yml -i inventory/staging
```

---

## Permanent Setup (Optional)

Add to `~/.bashrc` to auto-load:

```bash
# Ansible environment
alias ansible-start='source /home/jayps/ansible-env/bin/activate && cd /home/jayps/afrimart-ecommerce/ansible'
alias ansible-stop='deactivate'
```

Then use:
```bash
ansible-start  # Activates venv and enters ansible dir
```

---

## Files Structure

```
/home/jayps/ansible-env/            ← Virtual environment (created by you)
/home/jayps/afrimart-ecommerce/
├── ansible/                        ← Work here
│   ├── ansible.cfg                ← Configuration
│   ├── playbooks/
│   │   └── site.yml              ← Main playbook
│   ├── roles/                    ← 5 roles
│   ├── inventory/
│   │   ├── staging               ← Use this
│   │   ├── production            ← Or this
│   │   └── aws_ec2.yml          ← When AWS credentials ready
│   └── group_vars/              ← Variables
```

---

**Next Steps:** See `ansible/PHASE2_GUIDE.md` for deployment instructions!
