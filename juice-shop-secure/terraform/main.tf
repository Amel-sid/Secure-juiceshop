
locals {
  # Liste des chemins de clés possibles (en excluant les valeurs nulles ou vides)
  possible_key_paths = compact([
    var.ssh_key_path,
    "~/.ssh/vagrant_rsa",
    "~/.ssh/id_rsa",
    "${path.module}/../../vagrant/.vagrant/machines/default/virtualbox/private_key"
  ])
   resolved_paths = [for path in local.possible_key_paths : pathexpand(path)]
  
  # Trouver le premier fichier existant
  valid_key_path = try(
    [for path in local.resolved_paths : path if fileexists(path)][0],
    null
  )
  
  # Contenu de la clé
  ssh_private_key = local.valid_key_path != null ? file(local.valid_key_path) : null
}


resource "null_resource" "vm_provisioning" {
  triggers = {
    config_hash = filemd5("${path.module}/../secure-deploy/ansible/site.yml")
  }

 provisioner "remote-exec" {
  inline = [
    "sudo apt-get update -y && sudo apt-get install -y git",
    "cd /vagrant/secure-deploy || true && git pull || true",
    "cd /vagrant/secure-deploy/ansible",
    "ANSIBLE_CONFIG=./ansible.cfg ansible-playbook site.yml -i inventory | tee /tmp/ansible.log"
  ]
}


# pathexpand() pour convertir les chemins avec ~ en chemins absolus
 connection {
  type        = "ssh"
  user        = "vagrant"
  private_key = local.ssh_private_key

  host        = "127.0.0.1"
  port        = 2200
  timeout     = "900s"
  agent       = false
}
}