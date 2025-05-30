terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# ===================== CONFIGURATION LOCALE =====================
locals {
  # Configuration SSH sécurisée (A.9.4.2)
  ssh_port = var.ssh_port
  ssh_key_path = var.ssh_key_path != "" ? var.ssh_key_path : "${path.module}/../vagrant/.vagrant/machines/default/virtualbox/private_key"
  ssh_private_key = try(file(local.ssh_key_path), null)
  
  # Variables de sécurité conformes ISO 27001
  security_config = {
    admin_ip = var.admin_ip
    enable_firewall = var.enable_firewall
    enable_fail2ban = var.enable_fail2ban
    enable_apparmor = var.enable_apparmor
    tls_version = var.tls_version
  }
}

# ===================== VÉRIFICATIONS PRÉALABLES =====================

# Vérification clé SSH (A.9.4.2 - Accès système sécurisé)
resource "null_resource" "check_ssh_key" {
  lifecycle {
    precondition {
      condition     = local.ssh_private_key != null
      error_message = "SÉCURITÉ: Clé SSH Vagrant manquante: ${local.ssh_key_path}. Exécutez 'vagrant up' d'abord."
    }
  }

  triggers = {
    key_exists = fileexists(local.ssh_key_path) ? "true" : "false"
  }
}

# Test connectivité VM sécurisée
resource "null_resource" "vm_security_check" {
  depends_on = [null_resource.check_ssh_key]

  connection {
    type        = "ssh"
    user        = "vagrant"
    private_key = local.ssh_private_key
    host        = "127.0.0.1"
    port        = local.ssh_port
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '🛡️  VÉRIFICATION SÉCURITÉ SYSTÈME'",
      "echo '================================'",
      "echo 'Utilisateur: '$(whoami)",
      "echo 'Hostname: '$(hostname)",
      "echo 'Kernel: '$(uname -r)",
      "echo 'Uptime: '$(uptime -p)",
      "echo 'Services sécurité:'",
      "systemctl is-active ufw || echo 'UFW: non installé'", 
      "systemctl is-active fail2ban || echo 'Fail2ban: non installé'",
      "systemctl is-active apparmor || echo 'AppArmor: non installé'",
      "ls -la /vagrant/secure-deploy/ || echo '⚠️  Répertoire secure-deploy non monté'"
    ]
  }

  triggers = {
    security_check = timestamp()
  }
}

# ===================== VALIDATION ANSIBLE =====================

# Validation playbook Ansible (A.12.6.1 - Gestion vulnérabilités)
resource "null_resource" "ansible_validation" {
  depends_on = [null_resource.vm_security_check]

  connection {
    type        = "ssh"
    user        = "vagrant"
    private_key = local.ssh_private_key
    host        = "127.0.0.1"
    port        = local.ssh_port
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '📋 VALIDATION ANSIBLE SÉCURISÉ'",
      "echo '=============================='",
      "ansible --version || echo '❌ Ansible non installé'",
      "cd /vagrant/secure-deploy/ansible",
      "echo 'Fichiers de sécurité disponibles:'",
      "ls -la roles/*/tasks/main.yml",
      "echo '🧪 TEST PLAYBOOK (DRY-RUN SÉCURISÉ)'",
      "sudo ansible-playbook site.yml -i inventory --connection=local --check --diff || echo '⚠️  Playbook nécessite corrections'"
    ]
  }

  triggers = {
    playbook_hash = fileexists("${path.module}/../secure-deploy/ansible/site.yml") ? filemd5("${path.module}/../secure-deploy/ansible/site.yml") : "missing"
    roles_hash = fileexists("${path.module}/../secure-deploy/ansible/roles/hardening/tasks/main.yml") ? filemd5("${path.module}/../secure-deploy/ansible/roles/hardening/tasks/main.yml") : "missing"
  }
}

# ===================== EXÉCUTION SÉCURISÉE =====================

# Déploiement sécurisé avec Ansible (Conformité ISO 27001)
resource "null_resource" "secure_deployment" {
  depends_on = [null_resource.ansible_validation]
  count = var.run_ansible ? 1 : 0

  connection {
    type        = "ssh"
    user        = "vagrant"
    private_key = local.ssh_private_key
    host        = "127.0.0.1"
    port        = local.ssh_port
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '🚀 DÉPLOIEMENT SÉCURISÉ ISO 27001'",
      "echo '================================='",
      "cd /vagrant/secure-deploy/ansible",
      "sudo ansible-playbook site.yml -i inventory --connection=local -v --extra-vars '{\"admin_ip\":\"${local.security_config.admin_ip}\", \"enable_firewall\":${local.security_config.enable_firewall}, \"tls_version\":\"${local.security_config.tls_version}\"}'"
    ]
  }

  triggers = {
    security_config = jsonencode(local.security_config)
    force_run = var.force_ansible_run ? timestamp() : "disabled"
  }
}

# ===================== TESTS POST-DÉPLOIEMENT =====================

# Validation sécurité post-déploiement
resource "null_resource" "security_validation" {
  depends_on = [null_resource.secure_deployment]
  count = var.run_ansible && var.enable_security_validation ? 1 : 0

  connection {
    type        = "ssh"
    user        = "vagrant"
    private_key = local.ssh_private_key
    host        = "127.0.0.1"
    port        = local.ssh_port
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '🧪 TESTS SÉCURITÉ POST-DÉPLOIEMENT'",
      "echo '=================================='",
      "echo '1. Pare-feu UFW (A.13.1.1):'",
      "sudo ufw status verbose",
      "echo '2. Fail2ban (A.9.4.2):'", 
      "sudo fail2ban-client status",
      "echo '3. AppArmor (A.12.6.2):'",
      "sudo aa-status | head -10",
      "echo '4. Services Docker:'",
      "docker ps 2>/dev/null || echo 'Docker non démarré'",
      "echo '5. HTTPS TLS (A.13.2.1):'",
      "curl -k -I https://localhost || echo 'HTTPS non accessible'",
      "echo '6. Conteneurs sécurisés:'",
      "docker inspect juice-shop 2>/dev/null | grep -E '(SecurityOpt|User)' || echo 'juice-shop non déployé'"
    ]
  }

  triggers = {
    validation_run = timestamp()
  }
}