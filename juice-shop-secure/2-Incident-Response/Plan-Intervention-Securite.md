# Plan d'intervention incidents sécurité

## Objectif et périmètre

Ce plan définit les procédures standardisées de réponse aux incidents de sécurité selon le framework NIST SP 800-61r2. Il s'applique à tous les environnements (production, préprod, développement) et couvre les incidents de compromission, exfiltration de données, déni de service et malware.

---

## Phase 1 : Identification

### Détection

**Sources de détection :**
- Analyse des logs système (`/var/log/nginx/`, `/var/log/auth.log`)
- Monitoring applicatif (Docker logs)
- Contrôles manuels périodiques
- Alertes utilisateurs/équipes techniques
- Veille sécurité externe

**Critères d'escalade :**
- **P1 (Critique) :** Impact production, données sensibles compromises
- **P2 (Élevée) :** Impact préprod, tentative d'intrusion
- **P3 (Modérée) :** Activité suspecte sans impact immédiat

### Procédure d'analyse

1. **Collecte d'informations initiales**
   - Horodatage de détection
   - Systèmes impactés
   - Indicateurs de compromission (IoC)

2. **Analyse technique**
   - Examen des logs Nginx, authentification, applicatifs
   - Utilisation d'outils disponibles (`grep`, `jq`, `awk`)
   - Corrélation manuelle des événements
   - Identification du vecteur d'attaque
   - Évaluation de la portée

3. **Documentation**
   - Ouverture ticket avec classification
   - Notification canal #secops
   - Transmission IoC au RSSI

---

## Phase 2 : Containment

### Actions immédiates

**Validation hiérarchique requise pour :**
- Coupure de services
- Modification de configuration production
- Isolation de systèmes critiques

**Mesures techniques :**

1. **Isolation réseau**
   ```bash
   # Blocage IP malveillante
   ufw deny from [IP_SUSPECT]
   
   # Coupure temporaire service si nécessaire
   systemctl stop [SERVICE]
   ```

2. **Invalidation d'accès**
   - Révocation tokens/sessions actives
   - Désactivation comptes compromis
   - Flush cache authentification

3. **Préservation des preuves**
   - Snapshot des systèmes impactés
   - Archivage logs pertinents
   - Documentation des actions menées

### Coordination

- **Communication interne :** Canal #secops, ticket de suivi
- **Escalade :** RSSI, DPO selon impact
- **Communication externe :** Si clients impactés (validation direction)

---

## Phase 3 : Eradication

### Élimination de la menace

1. **Analyse root cause**
   - Identification du vecteur initial
   - Cartographie des systèmes compromis
   - Évaluation des vulnérabilités exploitées

2. **Assainissement**
   - Mise à jour des systèmes vulnérables
   - Suppression des artefacts malveillants
   - Correction des configurations défaillantes
   - Scan sécurité complet (Trivy, Nessus)

3. **Renforcement**
   - Durcissement des configurations
   - Mise à jour des règles de sécurité
   - Génération de nouveaux secrets/certificats

### Validation

- Scan de vulnérabilités post-correction
- Tests de non-régression
- Validation par l'équipe sécurité

---

## Phase 4 : Recovery

### Restauration des services

1. **Stratégie de restauration**
   - Utilisation de sauvegardes vérifiées
   - Tests fonctionnels complets
   - Validation de l'intégrité

2. **Remise en service progressive**
   - Environnement de test d'abord
   - Monitoring renforcé
   - Communication aux utilisateurs

3. **Surveillance post-incident**
   - Monitoring manuel renforcé 48-72h
   - Analyse quotidienne des logs
   - Recherche d'indicateurs de réinfection
   - Validation des métriques de performance disponibles

### Tests de validation

- **Tests fonctionnels :** Authentification, API critiques, flux métier
- **Tests sécurité :** Scan avec outils disponibles, revue manuelle configuration, test basique d'intrusion
- **Tests performance :** Charge normale, temps de réponse

---

## Conformité et gouvernance

### Obligations réglementaires

**RGPD (si données personnelles) :**
- Notification DPO immédiate
- Évaluation risque pour les personnes
- Déclaration CNIL si nécessaire (72h)
- Information personnes concernées (si risque élevé)

**ISO 27001 :**
- Documentation complète (A.16.1.5)
- Analyse post-incident (A.16.1.6)
- Mise à jour des procédures (A.16.1.7)

### Communication

- **Interne :** Équipes techniques, direction, juridique
- **Externe :** Clients, partenaires, autorités (selon impact)
- **Presse :** Validation direction générale uniquement

---

## Post-incident et amélioration continue

### Analyse post-incident

**Délai :** Dans les 5 jours ouvrés suivant la résolution

**Contenu obligatoire :**
- Timeline détaillée de l'incident
- Analyse des causes techniques et organisationnelles
- Évaluation de l'efficacité de la réponse
- Impact business et technique quantifié

### Plan d'amélioration

1. **Court terme (< 1 mois)**
   - Corrections techniques urgentes
   - Mise à jour procédures
   - Formation équipes si nécessaire

2. **Moyen terme (1-3 mois)**
   - Déploiement progressif d'outils de supervision centralisée
   - Automatisation du monitoring des logs critiques
   - Mise en place d'alerting basique
   - Tests de procédures

3. **Long terme (3-6 mois)**
   - Déploiement complet de la supervision centralisée
   - Évolution architecture sécurité
   - Intégration SIEM/SOAR
   - Exercices de simulation

### Métriques et KPI

- **MTTR (Mean Time To Recovery) :** < 4h pour P1, < 24h pour P2
- **MTTD (Mean Time To Detection) :** < 15 min automatisé, < 2h manuel
- **Taux de faux positifs :** < 5% des alertes
- **Couverture monitoring :** > 95% des assets critiques

---

## Contacts et ressources

### Équipe de réponse

- **Responsable sécurité :** [Contact 24/7]
- **Équipe technique :** Canal #secops
- **RSSI :** [Contact]
- **DPO :** [Contact]

### Outils et accès

- **Logs système :** Accès SSH aux serveurs, centralisation en cours
- **Gestion des incidents :** Tickets + canal #secops
- **Documentation :** Wiki interne, playbooks
- **Coffre de secrets :** En cours de déploiement
- **Outils d'analyse :** `grep`, `jq`, `awk`, Trivy, Postman

### Références

- **NIST SP 800-61r2 :** Computer Security Incident Handling Guide
- **PICERL :** Preparation, Identification, Containment, Eradication, Recovery, Lessons Learned
- **ISO 27001 :** Section A.16 (Gestion des incidents de sécurité)