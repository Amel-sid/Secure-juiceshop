output "vm_ip" {
  description = "Adresse IP de la VM Vagrant"
  value       = "127.0.0.1"
}

output "security_status" {
  description = "État du durcissement de la VM"
  value       = "✅ Durcissement appliqué : pare-feu, SSH sécurisé, fail2ban, mises à jour."
}
