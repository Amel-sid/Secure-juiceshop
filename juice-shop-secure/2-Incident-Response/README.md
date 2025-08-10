# Exercices 2 & 3 : Incident Response & Communication

## Structure du livrable

### Exercice 2 - Simulation de réponse aux incidents
1. **Plan-Intervention-Securite.md** : Plan d'intervention générique selon NIST SP 800-61r2
2. **Cas-Application-JuiceShop.md** : Application concrète du plan sur un incident réel

### Exercice 3 - Communication d'avis de sécurité  
3. **security-advisory.md** : Advisory client (JSB-2025-001) basé sur l'incident de l'exercice 2

## Approche

Le plan définit les procédures standardisées de réponse aux incidents de sécurité.
Le cas d'application démontre la mise en œuvre pratique de ces procédures sur un 
incident de compromission via credentials par défaut (21 mai 2025, préproduction JuiceShop).


## Cohérence du scénario

Les trois documents traitent du **même incident** :
- **Type :** Credentials par défaut non modifiés  
- **Impact :** 2,847 enregistrements test, aucune donnée client réelle
- **Durée :** 45 minutes d'exposition  
- **Environnement :** Préproduction uniquement

## Frameworks appliqués

- NIST SP 800-61r2 (Computer Security Incident Handling Guide)
- ISO 27001 A.16 (Gestion des incidents de sécurité)
- Éléments PICERL (Preparation, Identification, Containment, Eradication, Recovery, Lessons Learned)
- RGPD Article 33 (Déclaration préventive à la CNIL)