# ===================== VARIABLES EXÉCUTION =====================

variable "run_ansible" {
  description = "Exécuter le provisioning Ansible sécurisé"
  type        = bool
  default     = true
}

variable "force_ansible_run" {
  description = "Forcer l'exécution Ansible à chaque apply"
  type        = bool
  default     = false
}

variable "ssh_key_path" {
  description = "Chemin vers la clé SSH Vagrant"
  type        = string
  default     = ""
}

# ===================== VARIABLES SÉCURITÉ ISO 27001 =====================

variable "ssh_port" {
  description = "Port SSH sécurisé (A.9.4.2)"
  type        = number
  default     = 2222
  
  validation {
    condition     = var.ssh_port > 1024 && var.ssh_port < 65535
    error_message = "Port SSH doit être entre 1024 et 65535 pour sécurité."
  }
}

variable "admin_ip" {
  description = "IP administrateur autorisée (A.13.1.1)"
  type        = string
  default     = "0.0.0.0"
  
  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.admin_ip))
    error_message = "Format IP invalide - sécurité compromise."
  }
}

variable "enable_firewall" {
  description = "Activer UFW pare-feu (A.13.1.1)"
  type        = bool
  default     = true
}

variable "enable_fail2ban" {
  description = "Activer protection Fail2ban (A.9.4.2)"
  type        = bool
  default     = true
}

variable "enable_apparmor" {
  description = "Activer confinement AppArmor (A.12.6.2)"
  type        = bool
  default     = true
}

variable "tls_version" {
  description = "Version TLS minimale (A.13.2.1)"
  type        = string
  default     = "TLSv1.2"
  
  validation {
    condition     = contains(["TLSv1.2", "TLSv1.3"], var.tls_version)
    error_message = "TLS version doit être TLSv1.2 ou TLSv1.3 minimum."
  }
}

variable "enable_security_validation" {
  description = "Exécuter tests sécurité post-déploiement"
  type        = bool
  default     = true
}

# ===================== VARIABLES CONFORMITÉ =====================

variable "compliance_mode" {
  description = "Mode conformité (ISO27001, HDS, SOC2)"
  type        = string
  default     = "ISO27001"
  
  validation {
    condition     = contains(["ISO27001", "HDS", "SOC2"], var.compliance_mode)
    error_message = "Mode conformité supporté: ISO27001, HDS, SOC2."
  }
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "test"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environnement: dev, test, staging, prod."
  }
}