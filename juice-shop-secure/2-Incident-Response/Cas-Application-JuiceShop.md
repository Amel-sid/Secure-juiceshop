# Incident de sécurité – Juice Shop

## Date de détection
21 mai 2025, 10h42

---

## Résumé exécutif

Compromission du compte admin Juice Shop (préprod) via credentials par défaut. Exfiltration de 2,847 enregistrements clients fictifs (~2MB JSON) incluant emails, noms et historiques d'achat. Exposition de 45 minutes, downtime préprod de 45 minutes avec report des tests équipe dev. **Incident résolu, aucun impact production ni client externe.**

---

## Contexte

Lors d'un contrôle manuel en préprod, j'ai repéré dans les logs Nginx plusieurs connexions suspectes au compte `admin` depuis une IP inconnue (codes HTTP 200 répétés). 

Pas d'alerte automatique car la supervision centralisée n'est pas encore déployée. J'ai signalé sur #secops et ouvert un ticket prioritaire. L'environnement utilise des données de test structurées comme en production.

---

## Identification

**Analyse :** `grep 'POST /rest/user/login' /var/log/nginx/access.log | grep '95.211'`

Découverte de multiples connexions réussies depuis 95.211.xxx.xxx avec accès à `/api/Customers/export` retournant un JSON contenant 2,847 enregistrements clients fictifs (emails, noms, adresses, historiques d'achat). Bien que fictives, ces données reproduisent fidèlement la structure production. Le user-agent automatisé confirmait un scan scripte plutôt qu'une intrusion ciblée.

**Root cause :** Credentials par défaut Juice Shop non supprimés lors du déploiement.

IoC documentés et transmis au RSSI : IP source, endpoints ciblés, timeline des requêtes.

---

## Containment

Avec validation du référent, j'ai appliqué la coupure temporaire via `systemctl stop nginx` et bloqué l'IP avec UFW. Sessions invalidées par `FLUSHDB` sur Redis et compte admin supprimé dans MongoDB.

**Hypothèse confirmée :** Scan automatisé exploitant les credentials par défaut.

---

## Eradication

Mise à jour Juice Shop v15.2.1, nettoyage des comptes de test faibles. Nouveau compte admin généré via `openssl rand -base64 16` et stocké dans le coffre de secrets.

Scan Trivy du conteneur complété par une revue manuelle des endpoints exposés. Logs archivés pour analyse post-incident.

---

## Recovery

Restauration depuis le snapshot Vagrant quotidien du 28 mai (pré-testé). Tests fonctionnels complets : authentification, panier, API via Postman. Protection temporaire mise en place sur `/api/Customers/export`.

**Validation :** Aucun comportement anormal détecté.

---

## Conformité

DPO alerté et incident inscrit au registre. Déclaration CNIL préventive (Art. 33 RGPD) justifiée par la structure identique aux données production et le risque théorique de reconnaissance des patterns de données. Bien qu'aucun client réel ne soit impacté, la prudence s'imposait. Playbook mis à jour avec ce scénario.

**Framework appliqué :** NIST SP 800-61r2 + ISO 27001 A.16.1.5

---

## Bilan

**Points positifs :** La détection manuelle a bien fonctionné même sans alerting automatique. L'équipe a coordonné efficacement et on a appliqué la méthodologie NIST sans improviser. Impact limité au préprod uniquement.

**Impact opérationnel :** 45 minutes d'arrêt préprod, les tests dev ont été reportés de 2h. Coût faible, aucune vraie donnée client touchée.

**À améliorer :** Il faut accélérer le déploiement de la supervision centralisée. Le hardening post-déploiement doit être systématisé pour éviter ce genre d'oubli. Un minimum d'alerting sur les logs existants nous aurait aidés.

Cette expérience montre qu'on peut s'appuyer sur le monitoring humain mais qu'une réponse bien structurée reste indispensable pour garder le contrôle.

---

## Suivi

**Court terme :** Déploiement règle Falco production  
**Moyen terme :** Checklist hardening obligatoire  
**Long terme :** Supervision complète préprod

**Incident clos** - Leçons intégrées aux processus.