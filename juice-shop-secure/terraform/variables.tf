variable "ssh_port" {
  description = "Port SSH de la VM VirtualBox"
  type        = number
  default     = 2222  # Port forwardé par défaut via Vagrant
}

variable "vm_user" {
  description = "Utilisateur SSH pour se connecter à la VM"
  type        = string
  default     = "vagrant"
}

variable "ssh_key_path" {
  description = "Chemin vers la clé privée SSH (laisser vide pour détection automatique)"
  type        = string
  default     = null
}

variable "allowed_ports" {
  description = "Ports à ouvrir dans le pare-feu"
  type        = list(number)
  default     = [80, 443, 3000]  # Ports pour Juice Shop + HTTPS/HTTP
}

variable "inventory_file" {
  description = "Chemin du fichier d'inventaire Ansible"
  type        = string
  default     = "./inventory"
}