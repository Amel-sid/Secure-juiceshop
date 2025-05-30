# 📋 Compliance Mapping - ISO 27001 & HDS

## ISO 27001:2013 Controls Implementation

| Control | Description | Implementation | Evidence Location |
|---------|-------------|----------------|------------------|
| **A.9.2.3** | Management of privileged access rights | Container no-new-privileges, AppArmor profiles, Docker socket restrictions | `roles/juice/tasks/main.yml`, `roles/hardening/tasks/main.yml` |
| **A.9.4.2** | Secure log-on procedures | SSH hardening (MaxAuthTries=3, disabled forwarding), Fail2ban protection | `roles/hardening/tasks/main.yml`, `roles/fail2ban/tasks/main.yml` |
| **A.12.1.1** | Documented operating procedures | Ansible playbook orchestration, ordered security deployment | `site.yml`, role documentation |
| **A.12.1.2** | Change management | Unattended security updates, structured deployment process | `roles/hardening/tasks/main.yml`, `site.yml` |
| **A.12.1.3** | Capacity management | Container resource limits (512MB RAM, 50% CPU), nginx 128MB limit | `roles/juice/tasks/main.yml`, `roles/reverse_proxy/` |
| **A.12.4.1** | Event logging | Docker daemon logging, UFW medium logging, Fail2ban logs, nginx access/error logs | Multiple roles with logging config |
| **A.12.5.1** | Installation of software on operational systems | GPG-verified Docker installation from official repositories | `roles/docker/tasks/main.yml` |
| **A.12.6.1** | Management of technical vulnerabilities | Trivy vulnerability scanning, automated security updates | `roles/tools/tasks/main.yml`, `roles/hardening/tasks/main.yml` |
| **A.12.6.2** | Restrictions on software installation | AppArmor confinement, container security options, no-new-privileges | `roles/hardening/tasks/main.yml`, container configs |
| **A.13.1.1** | Network controls | UFW firewall with restrictive policy, port access control | `roles/hardening/tasks/main.yml` |
| **A.13.1.2** | Security of network services | Nginx reverse proxy configuration, service isolation via Docker networks | `roles/reverse_proxy/`, network isolation |
| **A.13.1.3** | Segregation in networks | Docker network isolation, reverse proxy acting as gateway | Docker network config, proxy setup |
| **A.13.2.1** | Information transfer policies and procedures | TLS 1.2+ enforcement, HTTPS-only access, secure ciphers | `reverse_proxy` TLS config, nginx template |
| **A.14.1.3** | Protection of application services transactions | TLS encryption, comprehensive security headers (HSTS, CSP, etc.) | Nginx security headers configuration |
| **A.14.2.2** | System security review procedures | Terraform security validation, post-deployment tests | `terraform/main.tf` security validation |
| **A.14.2.4** | Secure coding practices | GPG signature verification for Docker, integrity checks | `roles/docker/tasks/main.yml` |
| **A.14.2.5** | Secure system engineering principles | Vulnerability scanning integration, security-first architecture | `roles/tools/`, overall architecture |
| **A.16.1.4** | Assessment of security events | Fail2ban monitoring, automated response to intrusion attempts | `roles/fail2ban/tasks/main.yml` |

## HDS (Hébergement de Données de Santé) Compliance

| Article | Requirement | Implementation | Evidence |
|---------|-------------|----------------|----------|
| **Article 7** | Administration sécurisée | SSH hardening, automated updates, secure Docker config, Trivy scanning, orchestrated deployment | `roles/hardening/`, `roles/docker/`, `roles/tools/`, `site.yml` |
| **Article 8** | Traçabilité des accès et opérations | Comprehensive logging (Docker, UFW, Fail2ban, nginx), AppArmor profiles, container security audit trail | Docker daemon logs, AppArmor config, security logging across all services |
| **Article 9** | Chiffrement des données | TLS 1.2+ minimum, ECDHE-GCM ciphers, HTTPS enforcement, secure certificate management | `reverse_proxy` TLS config, nginx template with SSL settings |
| **Article 10** | Mesures de protection physique et logique | UFW firewall, network isolation, container confinement, security headers, access controls | Network controls, Docker security, comprehensive protection measures |
| **Article 11** | Contrôle d'accès logique | SSH access control, Fail2ban intrusion prevention, user privilege management, container isolation | SSH config, Fail2ban jails, access restrictions, privilege controls |

## Compliance Validation Commands

```bash
# Verify ISO 27001 A.9.4.2 (SSH Security)
sudo sshd -T | grep -E "(MaxAuthTries|X11Forwarding|AllowTcpForwarding)"

# Verify ISO 27001 A.13.1.1 (Network Controls)
sudo ufw status verbose

# Verify ISO 27001 A.12.6.1 (Vulnerability Management)
trivy --version && ls -la /home/vagrant/trivy-report.txt

# Verify HDS Article 9 (Encryption)
openssl s_client -connect localhost:443 -tls1_2 < /dev/null

# Verify HDS Article 11 (Access Control)
sudo fail2ban-client status

# Verify container security (Multiple controls)
docker inspect juice-shop | grep -E "(SecurityOpt|Memory|CpuQuota)"

# Verify security headers (A.14.1.3)
curl -k -I https://localhost | grep -E "(Strict-Transport-Security|X-Content-Type-Options|X-Frame-Options)"
```

## Audit Trail

| Date | Control | Status | Validator | Notes |
|------|---------|--------|-----------|-------|
| Deployment | All 18 ISO controls | ✅ Implemented | Terraform/Ansible | Automated validation |
| Deployment | All 5 HDS articles | ✅ Implemented | Infrastructure as Code | Comprehensive coverage |
| Post-deployment | Security tests | ✅ Passed | `security_validation` resource | 5+ validation checks |
| Continuous | Fail2ban monitoring | 🔄 Active | fail2ban service | Real-time protection |
| Continuous | Vulnerability scanning | 🔄 Available | Trivy reports | On-demand scanning |

## Non-Conformities and Mitigations

| Control | Issue | Mitigation | Status |
|---------|-------|------------|--------|
| A.9.4.2 | SSH port change disabled | Risk accepted for Vagrant compatibility | ⚠️ Documented |
| A.9.4.2 | SSH key-only auth disabled | Risk accepted for test environment | ⚠️ Documented |

**Note:** The identified non-conformities are acceptable for a test environment and do not compromise the overall security posture in a production deployment scenario.