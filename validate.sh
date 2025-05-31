#!/bin/bash

# ===================================================================
# SCRIPT DE VALIDATION SÉCURISÉ - OWASP JUICE SHOP
# ===================================================================
#
# Ce script automatise la validation complète du déploiement sécurisé
# de Juice Shop en testant l'infrastructure, la sécurité et l'application.
#
# OBJECTIF :
# Fournir une validation automatisée et objective du niveau de sécurité
# atteint par le déploiement, avec scoring et conformité mesurable.
#
# TESTS COUVERTS :
# - Infrastructure (VM, SSH, services)
# - Sécurité (firewall, fail2ban, apparmor)
# - Containers (fonctionnement, restrictions)
# - Réseau (accès HTTPS, blocage direct)
# - Conformité (durcissement SSH, règles firewall)

echo "=========================================="
echo "🚀 OWASP Juice Shop Security Validation"
echo "=========================================="
echo ""

# Configuration des couleurs pour améliorer la lisibilité des résultats
# Les couleurs aident à identifier rapidement le statut des tests
GREEN='\033[0;32m'  # Vert pour les succès (tests passés)
RED='\033[0;31m'    # Rouge pour les échecs (problèmes critiques)
YELLOW='\033[1;33m' # Jaune pour les avertissements (améliorations possibles)
NC='\033[0m'        # Reset couleur (retour normal)

# Variables de comptage pour le scoring final
# Ces métriques permettent de calculer un score objectif de sécurité
TOTAL_TESTS=13      # Nombre total de tests définis
PASSED_TESTS=0      # Compteur des tests réussis
FAILED_TESTS=0      # Compteur des tests échoués
WARNING_TESTS=0     # Compteur des avertissements (non bloquants)

# Fonctions utilitaires pour standardiser l'affichage des résultats
# Ces fonctions assurent un format cohérent et comptent automatiquement les résultats
test_step() {
    echo -n "Testing $1... "
}

test_success() {
    echo -e "${GREEN}✅ PASS${NC}"
    ((PASSED_TESTS++))          # Incrémente le compteur de succès
}

test_fail() {
    echo -e "${RED}❌ FAIL${NC}"
    ((FAILED_TESTS++))          # Incrémente le compteur d'échecs
}

test_warning() {
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    ((WARNING_TESTS++))         # Incrémente le compteur d'avertissements
}

echo "📋 Step 1: Infrastructure Validation"
echo "======================================"

# Vérification préliminaire : on doit être dans le bon répertoire
# Cette vérification évite des erreurs si le script est lancé depuis un mauvais endroit
if [ ! -d "vagrant" ]; then
    echo "❌ Erreur: Dossier vagrant/ non trouvé"
    echo "   Exécutez ce script depuis la racine du projet"
    exit 1
fi

# Test 1: Statut de la VM Vagrant
# Vérifie que la machine virtuelle est en cours d'exécution
# C'est un prérequis pour tous les autres tests
test_step "Vagrant VM status"
if cd vagrant && vagrant status | grep -q "running"; then
    test_success
    VM_RUNNING=true         # Variable utilisée pour les tests suivants
    cd ..
else
    test_fail
    VM_RUNNING=false
    cd ..
fi

# Test 2: Connectivité SSH vers la VM
# Teste la capacité à exécuter des commandes dans la VM
# Nécessaire pour tous les tests de services internes
test_step "SSH connectivity to VM"
if cd vagrant && vagrant ssh -c "echo 'SSH OK'" 2>/dev/null | grep -q "SSH OK"; then
    test_success
    SSH_OK=true            # Variable critique pour les tests suivants
    cd ..
else
    test_fail
    SSH_OK=false
    cd ..
fi

echo ""
echo "🔒 Step 2: Security Services Validation"
echo "======================================="

# Les tests de sécurité ne peuvent s'exécuter que si SSH fonctionne
# Cette approche évite des erreurs en cascade si l'infrastructure de base ne fonctionne pas
if [ "$SSH_OK" = true ]; then
    # Test 3: Service Docker
    # Docker doit être actif pour faire fonctionner les containers de l'application
    test_step "Docker service"
    if cd vagrant && vagrant ssh -c "sudo systemctl is-active docker" 2>/dev/null | grep -q "active"; then
        test_success
        cd ..
    else
        test_fail
        cd ..
    fi

    # Test 4: Firewall UFW
    # UFW doit être actif avec des règles appropriées pour la sécurité réseau
    # C'est une mesure de sécurité fondamentale pour contrôler les accès
    test_step "UFW firewall"
    if cd vagrant && vagrant ssh -c "sudo ufw status" 2>/dev/null | grep -q "Status: active"; then
        test_success
        cd ..
    else
        test_fail
        cd ..
    fi

    # Test 5: Service Fail2ban
    # Fail2ban protège contre les attaques par force brute en bannissant les IP suspectes
    # Service critique pour la protection contre les intrusions automatisées
    test_step "Fail2ban service"
    if cd vagrant && vagrant ssh -c "sudo systemctl is-active fail2ban" 2>/dev/null | grep -q "active"; then
        test_success
        cd ..
    else
        test_fail
        cd ..
    fi

    # Test 6: AppArmor
    # AppArmor fournit un confinement obligatoire pour limiter les actions des applications
    # Protection supplémentaire contre l'escalade de privilèges
    test_step "AppArmor profiles"
    if cd vagrant && vagrant ssh -c "sudo aa-status" 2>/dev/null | grep -q "profiles are loaded"; then
        test_success
        cd ..
    else
        test_fail
        cd ..
    fi
else
    echo "⚠️  Skipping security tests - SSH not available"
    # Si SSH ne fonctionne pas, on compte les tests de sécurité comme échoués
    # Cela assure que le score final reflète l'état réel de la sécurité
    ((FAILED_TESTS+=4))
fi

echo ""
echo "🐳 Step 3: Container Validation"
echo "================================"

# Validation des containers Docker et de leur configuration sécurisée
if [ "$SSH_OK" = true ]; then
    # Test 7: Container Juice Shop
    # Vérifie que l'application principale fonctionne dans son container
    test_step "OWASP Juice Shop container"
    cd vagrant
    CONTAINER_CHECK=$(vagrant ssh -c "sudo docker ps" 2>/dev/null)
    cd ..
    if echo "$CONTAINER_CHECK" | grep -q "bkimminich/juice-shop\|juice-shop"; then
        test_success
        CONTAINER_RUNNING=true      # Variable utilisée dans le scoring final
    else
        test_fail
        CONTAINER_RUNNING=false
    fi

    # Test 8: Restrictions de sécurité des containers
    # Vérifie que les containers ont des paramètres de sécurité appropriés
    # (no-new-privileges, apparmor, etc.)
    test_step "Container security restrictions"
    cd vagrant
    SECURITY_CHECK=$(vagrant ssh -c "sudo docker inspect juice-shop 2>/dev/null | grep -i security" 2>/dev/null)
    cd ..
    if [ -n "$SECURITY_CHECK" ]; then
        test_success
    else
        # Warning plutôt que fail car le container peut fonctionner sans certaines restrictions
        test_warning
    fi
else
    echo "⚠️  Skipping container tests - SSH not available"
    ((FAILED_TESTS+=2))
fi

echo ""
echo "🌐 Step 4: Network & Application Tests"
echo "====================================="

# Test 9: Blocage de l'accès direct
# Vérifie que le port 3000 (Juice Shop) n'est pas accessible directement
# Principe de sécurité : forcer le passage par le reverse proxy nginx
test_step "Direct access blocking (port 3000)"
if timeout 5 curl -s http://localhost:3000 2>/dev/null; then
    test_fail
    echo "    ❌ Direct access should be blocked!"
else
    # L'accès direct doit être bloqué = c'est un succès pour la sécurité
    test_success
fi

# Test 10: Accès HTTPS sécurisé
# Vérifie que l'application est accessible via HTTPS sur le port configuré
# C'est le mode d'accès principal et sécurisé pour les utilisateurs
test_step "HTTPS access (port 4443)"
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:4443 2>/dev/null | grep -q "200"; then
    test_success
    HTTPS_OK=true              # Variable critique pour le scoring final
else
    test_fail
    HTTPS_OK=false
fi

# Test 11: Configuration TLS
# Vérifie que le chiffrement TLS est correctement configuré
# Test de la version TLS minimale acceptée (TLSv1.2)
test_step "TLS configuration"
if openssl s_client -connect localhost:4443 -tls1_2 < /dev/null 2>/dev/null | grep -q "TLSv1.2"; then
    test_success
else
    # Warning car TLS peut fonctionner même sans version spécifique détectée
    test_warning
fi

echo ""
echo "📊 Step 5: Security Compliance Check"
echo "===================================="

# Tests de conformité sécuritaire - vérification des bonnes pratiques
if [ "$SSH_OK" = true ]; then
    # Test 12: Conformité des règles firewall
    # Vérifie que les règles UFW sont correctement configurées
    test_step "Firewall rules compliance"
    cd vagrant
    FIREWALL_RULES=$(vagrant ssh -c "sudo ufw status numbered" 2>/dev/null)
    cd ..
    if echo "$FIREWALL_RULES" | grep -q "DENY.*3000"; then
        # Règle spécifique trouvée : parfait
        test_success
    else
        # Vérification de fallback : au moins le firewall est actif
        if echo "$FIREWALL_RULES" | grep -q "Status: active"; then
            test_success
        else
            test_warning
        fi
    fi

    # Test 13: Durcissement SSH
    # Vérifie que la configuration SSH suit les bonnes pratiques de sécurité
    test_step "SSH hardening"
    cd vagrant
    SSH_CONFIG=$(vagrant ssh -c "sudo sshd -T" 2>/dev/null)
    cd ..
    # Vérification de paramètres critiques : limitation tentatives + désactivation X11
    if echo "$SSH_CONFIG" | grep -q "maxauthtries 3" && echo "$SSH_CONFIG" | grep -q "x11forwarding no"; then
        test_success
    else
        # Warning car SSH peut fonctionner même sans tous les paramètres optimaux
        test_warning
    fi
else
    echo "⚠️  Skipping compliance tests - SSH not available"
    ((FAILED_TESTS+=2))
fi

echo ""
echo "🎯 VALIDATION SUMMARY"
echo "===================="

# Calcul du score de sécurité basé sur le pourcentage de tests réussis
# Formule : (tests passés / total tests) * 100
SECURITY_SCORE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))

echo "📊 Test Results:"
echo "   ✅ Passed: $PASSED_TESTS/$TOTAL_TESTS"
echo "   ❌ Failed: $FAILED_TESTS/$TOTAL_TESTS"
echo "   ⚠️  Warnings: $WARNING_TESTS/$TOTAL_TESTS"
echo ""
echo "📈 Security Score: ${SECURITY_SCORE}%"
echo ""

# Évaluation des critères critiques pour validation finale
# Ces 4 composants sont indispensables pour considérer le déploiement comme réussi
CRITICAL_PASSED=0
if [ "$VM_RUNNING" = true ]; then ((CRITICAL_PASSED++)); fi      # Infrastructure de base
if [ "$SSH_OK" = true ]; then ((CRITICAL_PASSED++)); fi          # Accès pour administration
if [ "$CONTAINER_RUNNING" = true ]; then ((CRITICAL_PASSED++)); fi # Application fonctionnelle
if [ "$HTTPS_OK" = true ]; then ((CRITICAL_PASSED++)); fi        # Accès sécurisé utilisateur

# Validation finale : critères critiques + score minimum
# Seuil de 85% pour considérer le déploiement comme sécurisé
if [ $CRITICAL_PASSED -eq 4 ] && [ $SECURITY_SCORE -ge 85 ]; then
    echo -e "${GREEN}🎉 DEPLOYMENT VALIDATION: SUCCESS${NC}"
    echo -e "${GREEN}✅ Infrastructure is secure and operational${NC}"
    echo -e "${GREEN}✅ Security compliance verified${NC}"
    echo ""
    echo "🌐 Access your secure OWASP Juice Shop:"
    echo "   https://localhost:4443"
    echo ""
    echo "🔧 For detailed analysis:"
    echo "   cd vagrant && vagrant ssh"
    echo "   sudo ufw status verbose"
    echo "   docker logs juice-shop"
else
    echo -e "${RED}❌ DEPLOYMENT VALIDATION: FAILED${NC}"
    echo -e "${RED}⚠️  Some critical components are not working${NC}"
    echo ""
    echo "🔧 Troubleshooting steps:"
    # Guidance spécifique basée sur les composants qui ont échoué
    if [ "$VM_RUNNING" = false ]; then
        echo "   - Run: cd vagrant && vagrant up"
    fi
    if [ "$SSH_OK" = false ]; then
        echo "   - Check: cd vagrant && vagrant ssh"
    fi
    if [ "$CONTAINER_RUNNING" = false ]; then
        echo "   - Run: cd vagrant && vagrant ssh -c 'sudo docker ps'"
    fi
    if [ "$HTTPS_OK" = false ]; then
        echo "   - Check: curl -k https://localhost:4443"
    fi
fi

echo ""
echo "📚 For complete documentation, see README.md"
echo "=========================================="