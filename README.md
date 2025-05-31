# Test technique – Security Engineer @Scalingo

Ce dépôt contient deux livrables principaux correspondant aux attentes du test :

---

## 1️⃣ Sécurisation de l'infrastructure (Juice Shop)

* [📋 Guide de déploiement complet avec preuves](./juice-shop-secure/docs/DEPLOYMENT_PROOF.md)
* [🔒 Infrastructure sécurisée avec Terraform](./juice-shop-secure/terraform/)
* [⚙️ Automatisation Ansible](./juice-shop-secure/secure-deploy/)
* [✅ Script de validation automatique](./validate.sh)
- [📋 Compliance Mapping](./juice-shop-secure/docs/COMPLIANCE_MAPPING.md)

---

## 2️⃣ Réponse à un incident simulé

* [🚨 Plan d'intervention sécurité](./juice-shop-secure/2-Incident-Response/)
* [🔍 Procédures de réponse à incident](./juice-shop-secure/2-Incident-Response/)

---
## IA Usage
*  [Note de l'usage de l'ia](./juice-shop-secure/docs/AI_USAGE.md)


## 🚀 Démarrage rapide

```bash
# 1. Déployer l'infrastructure sécurisée
cd vagrant && vagrant up
cd ../juice-shop-secure/terraform && terraform apply

# 2. Valider le déploiement
./validate.sh

# 3. Accéder à l'application
# HTTPS sécurisé : https://localhost:4443
# SSH sécurisé : vagrant ssh
```

---

## 📚 Structure du projet

```
├── vagrant/                    # Configuration VM Ubuntu 24.04
├── juice-shop-secure/         # Infrastructure sécurisée
│   ├── terraform/             # Provisioning avec sécurité ISO 27001
│   ├── secure-deploy/         # Ansible automation & hardening
│   ├── docs/                  # Documentation avec captures
│   └── 2-Incident-Response/   # Procédures d'incident
├── validate.sh                # Script de validation sécurité
└── README.md                  # Ce fichier
```

Chaque partie peut être lue indépendamment, mais forme un ensemble cohérent sur l'approche sécurité proposée.