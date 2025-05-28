resource "null_resource" "vm_hardening" {
  triggers = {
    vagrant_state = filemd5("../../vagrant/Vagrantfile")
  }

   provisioner "remote-exec" {
    inline = [
      "cd /vagrant/secure-deploy/ansible",
      "ansible-playbook site.yml -i inventory"
    ]
  }

 connection {
  type        = "ssh"
  user        = "vagrant"
  private_key = file("/home/amel/juice-shop-push/vagrant/.vagrant/machines/default/virtualbox/private_key")
  host        = "127.0.0.1"
  port        = 2200
  timeout     = "90s"
}



  provisioner "remote-exec" {
    inline = [
  "echo '1️⃣ update'",
  "sudo DEBIAN_FRONTEND=noninteractive apt-get update -y",
  
  "echo '2️⃣ upgrade'",
  "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",

  "echo '3️⃣ UFW rules'",
  "sudo ufw allow 80/tcp",
  "sudo ufw allow 443/tcp",
  "sudo ufw --force enable",

  "echo '4️⃣ Disable root SSH'",
  "sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config || true",
  "sudo systemctl restart sshd",

  "echo '5️⃣ Install fail2ban'",
  "sudo apt-get install -y fail2ban",
  "sudo systemctl enable fail2ban",

  "echo '✅ Hardening complete'"
]

  }
}
