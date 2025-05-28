# #!/bin/sh

# set -e
# export DEBIAN_FRONTEND=noninteractive

# echo ">>> [1] Ajout de la clé GPG Docker"
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# echo "✅ Clé GPG ajoutée"

# echo ">>> [2] Ajout du dépôt Docker"
# sudo bash -c 'echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker-ce.list'
# echo "✅ Dépôt Docker ajouté"

# echo ">>> [3] Mise à jour et upgrade du système"
# timedatectl set-ntp true
# ntpdate ntp.ubuntu.com || true
# apt-get update -o Acquire::Retries=5 -o Acquire::http::Timeout="20" -q
# apt-get upgrade --fix-missing -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -yq
# echo "✅ Système mis à jour"

# echo ">>> [4] Installation d'Apache et Docker"
# apt-get install -qy apache2 docker-ce
# echo "✅ Apache et Docker installés"

# echo ">>> [5] Configuration Apache"
# cp /vagrant/default.conf /etc/apache2/sites-available/000-default.conf
# echo "✅ Fichier de conf copié"

# echo ">>> [6] Lancement du conteneur Juice Shop"
# if ! docker ps -a --format '{{.Names}}' | grep -q '^juice-shop$'; then
#   echo ">>> Conteneur Juice Shop non présent, lancement en cours"
#   docker run --restart=always -d -p 3000:3000 --name juice-shop bkimminich/juice-shop
# else
#   echo "✅ Conteneur Juice Shop déjà existant"
# fi
# echo "✅ Conteneur Juice Shop lancé"

# echo ">>> [7] Activation du proxy Apache"
# a2enmod proxy_http
# systemctl restart apache2.service
# echo "✅ Apache redémarré avec le module proxy"

# echo ">>> [8] Installation d'Ansible"
# apt-get install -y ansible
# echo "✅ Ansible installé"

# echo "🎉 Bootstrap terminé avec succès"
#!/bin/sh
set -e
export DEBIAN_FRONTEND=noninteractive

echo ">>> Mise à jour minimale de la VM"
apt-get update -yq
apt-get upgrade -yq
echo "✅ VM prête, Ansible peut prendre le relais"
