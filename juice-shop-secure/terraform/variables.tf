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

variable "allowed_ports" {
  description = "Ports à ouvrir dans le pare-feu"
  type        = list(number)
  default     = [80, 443, 3000]  # Ports pour Juice Shop + HTTPS/HTTP
}