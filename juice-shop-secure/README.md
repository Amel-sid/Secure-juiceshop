# Scalingo Security Engineer Technical Test

## 🚀 Quick Start
```bash
git clone git@github.com:Amel-sid/test-scalingo.git
cd test-scalingo
```

## Résultats
- 10 mesures de sécurité ✅
- 18 contrôles ISO 27001 ✅  
- Tests automatisés ✅

## Structure du projet
## 📁 Structure du projet

**📦 test-scalingo/**
- `README.md` - Guide principal
- **juice-shop-secure/** - Exercise 1: Infrastructure Hardening
 - `README.md` - Instructions déploiement
 - `terraform/` - Infrastructure as Code
 - `secure-deploy/` - Rôles Ansible sécurisés
   - `ansible/roles/` - 6 rôles de sécurité (docker, fail2ban, hardening...)
 - `2-Incident-Response/` - Exercises 2 & 3
   - `incident-plan.md` - Plan de réponse incident
   - `security-advisory.md` - Communication client
 - `docs/` - Documentation technique
   - `screenshots/` - Preuves visuelles
- **vagrant/** - Configuration VM
 - `secure-deploy/` - Lien vers Ansible
- `[autres dossiers...]` - Code source OWASP Juice Shop

## 🎯 Points d'entrée par exercice
- **Exercise 1 :** `cd juice-shop-secure/` → Voir README pour déploiement
- **Exercise 2-3 :** `cd juice-shop-secure/2-Incident-Response/` → Documentation incident
## Documentation
- [Security Measures](docs/SECURITY_MEASURES.md)
- [Compliance Mapping](docs/COMPLIANCE_MAPPING.md)
- [AI Usage](docs/AI_USAGE.md)

- [Incident Response](2-Incident-Response/)

