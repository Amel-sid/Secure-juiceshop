# 🛡️ Sécurisation OWASP Juice Shop – Environnement PaaS

## 🎯 Objectif

Déployer l'application vulnérable Juice Shop dans une VM Ubuntu 24.04 via Vagrant,  
et appliquer un ensemble de mesures de sécurité ISO 27001 / HDS côté système et conteneur.

---

## 🔧 Stack technique

- Vagrant + VirtualBox
- Ubuntu 24.04 (noble)
- Docker CE
- Ansible (provisionnement)
- Juice Shop (Docker container)

---

## 🔐 Mesures de sécurisation appliquées

| 🔒 Mesure                                    | Détail technique                                                                      | Référence ISO/HDS               |
|---------------------------------------------|----------------------------------------------------------------------------------------|----------------------------------|
| **Pare-feu UFW**                            | Politique par défaut `deny`, ports 22 et 3000 autorisés uniquement                     | A.13.1.1                         |
| **Durcissement SSH**                        | Interdiction `root`, désactivation mot de passe                                        | A.9.2.3 / HDS 7.1.2              |
| **User Docker non-root**                    | Le conteneur Juice Shop tourne sous `node` et non `root`                              | A.9.2.3 / A.14.2.8               |
| **Suppression capacités excessives**        | Seule `CAP_NET_BIND_SERVICE` est conservée                                            | A.13.2.1                         |
| **Docker sans volumes ni privilèges**       | Aucun montage hôte, pas de `--privileged`, pas d'accès au `docker.sock`               | A.11.2.6 / HDS 7.4.1             |
| **Gestion via Ansible**                     | Déploiement idempotent, traçabilité des actions système                               | A.12.1.2 / A.14.2.1              |

---

## 🧪 Tests inclus

- Vérification du port 3000 ouvert (`curl`, `ufw status`)
- Contrôle de l’utilisateur Docker (`docker inspect`)
- Vérification conteneur fonctionnel (`node -v`)

---

## ❗ Remarques

- L’image Juice Shop étant volontairement vulnérable, seules les couches **infra & conteneur** ont été sécurisées.
- Aucun `--privileged`, pas d’exposition de ports ou de volumes sensibles.
- L’heure système peut causer des erreurs `apt` : utiliser `ntpdate` pour forcer la synchro.

---

## ▶️ Lancer l’environnement

```bash
vagrant up
vagrant ssh
cd /vagrant/secure-deploy/ansible
ansible-playbook -i inventory site.yml


## 🌐 Sécurisation réseau du conteneur Juice Shop

### Objectif :
Isoler le conteneur Juice Shop dans un réseau Docker privé pour limiter les mouvements latéraux, les scans internes et les exfiltrations de données.

---

### 🔒 Mesure appliquée

| Action                           | Détail technique                                               | Référence |
|----------------------------------|----------------------------------------------------------------|-----------|
| Création d’un réseau Docker      | `docker_network` nommé `juice_net`, de type `bridge`           | ISO A.13.1.1 |
| Affectation du conteneur au réseau | `network_mode: juice_net` dans la task Ansible `docker_container` | HDS 7.4.2  |
| Capacité minimale conservée      | `CAP_NET_BIND_SERVICE` pour exposer le port 3000 uniquement    | ISO A.13.2.1 |
| Pas de communication inter-conteneur | Pas d’accès à d’autres conteneurs ou services internes         | ISO A.13.1.3 |

---

### ✅ Résultat

- Le conteneur Juice Shop est totalement isolé réseau.
- Aucun autre conteneur ne peut le contacter directement.
- Juice Shop n’a pas accès à Internet (si `internal: yes` est activé).
- Le pare-feu (UFW) bloque tous les ports sauf 3000 et SSH.

---

### 🔍 Vérification

```bash
docker network inspect juice_net
docker inspect juice-shop | grep juice_net

## 🛡️ Trivy — Scan de Sécurité Automatisé

L'outil **Trivy** est intégré dans le provisioning Ansible pour scanner automatiquement l’image Docker utilisée (`bkimminich/juice-shop`) et détecter d’éventuelles vulnérabilités connues.

### 🎯 Objectifs

- Identifier les **CVE critiques et majeures** présentes dans l'image
- Appliquer une politique de **gestion proactive des vulnérabilités** (ISO 27001 – A.12.6.1)
- Renforcer la sécurité de la supply chain logicielle dans une démarche DevSecOps

### ⚙️ Fonctionnement Automatisé

Lors de l'exécution de :

```bash
vagrant up --provision
Le rôle Ansible tools :

installe Trivy

scanne automatiquement l'image Juice Shop

enregistre le rapport dans le fichier :

arduino
Copy
Edit
/home/vagrant/trivy-report.txt
🧪 Utilisation manuelle dans la VM
bash
Copy
Edit
vagrant ssh
trivy image bkimminich/juice-shop
Exemple de sortie :

less
Copy
Edit
bkimminich/juice-shop (debian 12)
├── [CRITICAL] nodejs: CVE-2023-1234
├── [HIGH] libssl: CVE-2023-4567
...

