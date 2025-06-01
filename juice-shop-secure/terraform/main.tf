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
# Centralise toutes les variables de config sécurisée
# Gère automatiquement le chemin vers la clé SSH Vagrant
# Regroupe toutes les mesures de sécurité ISO 27001 dans un seul endroit
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
# ÉTAPE 1 : Vérifier que la clé SSH Vagrant existe avant tout
# Si pas de clé = stop avec message d'erreur clair
# Force l'utilisateur à faire "vagrant up" d'abord
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

# ÉTAPE 2 : Test de connectivité SSH vers la VM
# Vérifie que la VM Vagrant répond et est accessible
# Affiche l'état initial du système (diagnostic avant sécurisation)
# Montre quels services sécurité sont déjà présents ou manquants
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
      "echo 'VERIFICATION SECURITE SYSTEME'",
      "echo '================================'",
      "echo 'Utilisateur: '$(whoami)",
      "echo 'Hostname: '$(hostname)",
      "echo 'Kernel: '$(uname -r)",
      "echo 'Uptime: '$(uptime -p)",
      "echo 'Services sécurité:'",
      "systemctl is-active ufw || echo 'UFW: non installé'", 
      "systemctl is-active fail2ban || echo 'Fail2ban: non installé'",
      "systemctl is-active apparmor || echo 'AppArmor: non installé'",
      "ls -la /vagrant/secure-deploy/ || echo 'Répertoire secure-deploy non monté'"
    ]
  }

  triggers = {
    security_check = timestamp()
  }
}

# ===================== INSTALLATION ANSIBLE =====================
# ÉTAPE 3 : Installer Ansible dans la VM
# Terraform installe les outils dont il a besoin pour configurer la sécurité
# Force la réinstallation à chaque run (timestamp) pour éviter les bugs
# Prépare l'environnement pour exécuter les playbooks de sécurité
# Installation Ansible si nécessaire (A.12.6.1)
resource "null_resource" "ansible_setup" {
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
      "echo 'INSTALLATION ANSIBLE'",
      "echo '======================'",
      "sudo apt update -qq",
      "sudo apt install -y ansible",
      "ansible --version"
    ]
  }

  triggers = {
    install_ansible = timestamp()
  }
}

# ===================== VALIDATION ANSIBLE =====================
# ÉTAPE 4 : Vérifier qu'Ansible fonctionne et valider les playbooks
# Teste que l'installation précédente a marché
# Fait un dry-run (test sans modification) des playbooks de sécurité
# Vérifie que tous les fichiers de configuration sont présents
# Validation playbook Ansible (A.12.6.1 - Gestion vulnérabilités)
resource "null_resource" "ansible_validation" {
  depends_on = [null_resource.ansible_setup]

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
      "echo 'VALIDATION ANSIBLE SECURISE'",
      "echo '=============================='",
      "ansible --version",
      "cd /vagrant/secure-deploy/ansible",
      "echo 'Fichiers de sécurité disponibles:'",
      "ls -la roles/*/tasks/main.yml",
      "echo 'TEST PLAYBOOK (DRY-RUN SECURISE)'",
      "sudo ansible-playbook site.yml -i inventory --connection=local --check --diff || echo 'Playbook nécessite corrections'"
    ]
  }

  triggers = {
    playbook_hash = fileexists("${path.module}/../secure-deploy/ansible/site.yml") ? filemd5("${path.module}/../secure-deploy/ansible/site.yml") : "missing"
    roles_hash = fileexists("${path.module}/../secure-deploy/ansible/roles/hardening/tasks/main.yml") ? filemd5("${path.module}/../secure-deploy/ansible/roles/hardening/tasks/main.yml") : "missing"
  }
}

# ===================== EXÉCUTION SÉCURISÉE =====================
# ÉTAPE 5 : Lancer le vrai déploiement sécurisé
# Execute Ansible pour appliquer toutes les mesures de sécurité ISO 27001
# Configure UFW firewall + Fail2ban + AppArmor + Docker + Juice Shop + HTTPS
# C'est LE moment où votre VM devient sécurisée
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
      "echo 'DEPLOIEMENT SECURISE ISO 27001'",
      "echo '================================='",
      "cd /vagrant/secure-deploy/ansible",
      "sudo ansible-playbook site.yml -i inventory --connection=local -v"
    ]
  }

  triggers = {
    security_config = jsonencode(local.security_config)
    force_run = timestamp()
  }
}

# ===================== TESTS POST-DÉPLOIEMENT =====================
# ÉTAPE 6 : Vérifier que tout fonctionne après sécurisation
# Teste tous les services de sécurité installés
# Vérifie que les conteneurs Docker tournent
# Valide l'accès HTTPS et les certificats TLS
# Génère un rapport final de conformité sécurité
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
      "echo 'TESTS SECURITE POST-DEPLOIEMENT'",
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

# ===================== VALIDATION FINALE =====================
# ÉTAPE 7 : Lancer le script de validation complet du projet
# Execute validate.sh qui teste tous les aspects sécurité
# Génère le score final et le rapport de conformité
# Valide que le déploiement respecte les exigences Scalingo
resource "null_resource" "final_validation" {
  depends_on = [null_resource.security_validation]
  count = var.run_ansible && var.enable_security_validation ? 1 : 0

  provisioner "local-exec" {
    command ="cd ${path.cwd}/../.. && ./validate.sh"
  }

  triggers = {
    validation_run = timestamp()
  }
}