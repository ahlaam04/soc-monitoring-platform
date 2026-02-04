#!/bin/bash

# ==========================================
# Health Check Script - SOC Monitoring Platform
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        🏥 HEALTH CHECK - SOC MONITORING PLATFORM        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

passed=0
failed=0

check_service() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo -n "Checking $name... "
    
    if curl -sf "$url" | grep -q "$expected" 2>/dev/null; then
        echo -e "${GREEN}✅ OK${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((failed++))
    fi
}

check_docker_service() {
    local name=$1
    
    echo -n "Checking Docker service $name... "
    
    if docker ps --format '{{.Names}}' | grep -q "^$name$"; then
        echo -e "${GREEN}✅ Running${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ Not Running${NC}"
        ((failed++))
    fi
}

check_port() {
    local name=$1
    local port=$2
    
    echo -n "Checking port $port ($name)... "
    
    if nc -z localhost "$port" 2>/dev/null; then
        echo -e "${GREEN}✅ Open${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ Closed${NC}"
        ((failed++))
    fi
}

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}1. DOCKER SERVICES STATUS${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_docker_service "juice-shop"
check_docker_service "prometheus"
check_docker_service "grafana"
check_docker_service "alertmanager"
check_docker_service "node-exporter"
check_docker_service "cadvisor"
check_docker_service "blackbox-exporter"

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2. NETWORK PORTS${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_port "Juice Shop" 3000
check_port "Grafana" 3001
check_port "Prometheus" 9090
check_port "AlertManager" 9093
check_port "Node Exporter" 9100
check_port "cAdvisor" 8080
check_port "Blackbox Exporter" 9115

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3. WEB INTERFACES${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_service "Juice Shop" "http://localhost:3000" "Juice"
check_service "Prometheus" "http://localhost:9090" "Prometheus"
check_service "Grafana" "http://localhost:3001/api/health" "ok"
check_service "AlertManager" "http://localhost:9093" "Alertmanager"

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}4. PROMETHEUS TARGETS${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -n "Checking Prometheus targets... "
targets=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.health=="up") | .labels.job' 2>/dev/null)

if [ -n "$targets" ]; then
    echo -e "${GREEN}✅ OK${NC}"
    ((passed++))
    echo "Active targets:"
    echo "$targets" | while read target; do
        echo "  • $target"
    done
else
    echo -e "${RED}❌ FAILED${NC}"
    ((failed++))
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}5. ALERTMANAGER STATUS${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -n "Checking AlertManager... "
am_status=$(curl -s http://localhost:9093/api/v2/status 2>/dev/null)

if [ -n "$am_status" ]; then
    echo -e "${GREEN}✅ OK${NC}"
    ((passed++))
else
    echo -e "${RED}❌ FAILED${NC}"
    ((failed++))
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}6. GRAFANA DASHBOARDS${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -n "Checking Grafana dashboards... "
dashboards=$(curl -s -u admin:admin123 http://localhost:3001/api/search?type=dash-db 2>/dev/null | jq -r '.[].title' 2>/dev/null)

if [ -n "$dashboards" ]; then
    echo -e "${GREEN}✅ OK${NC}"
    ((passed++))
    echo "Available dashboards:"
    echo "$dashboards" | while read dash; do
        echo "  • $dash"
    done
else
    echo -e "${RED}❌ FAILED${NC}"
    ((failed++))
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}7. CONFIGURATION FILES${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

files=(
    "docker-compose.yml"
    "prometheus/prometheus.yml"
    "prometheus/alerts.yml"
    "alertmanager/alertmanager.yml"
)

for file in "${files[@]}"; do
    echo -n "Checking $file... "
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ Exists${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ Missing${NC}"
        ((failed++))
    fi
done

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SUMMARY${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

total=$((passed + failed))
percentage=$((passed * 100 / total))

echo ""
echo -e "Total checks: $total"
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${RED}Failed: $failed${NC}"
echo -e "Success rate: $percentage%"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✅ ALL CHECKS PASSED - PLATFORM IS HEALTHY ✅        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ⚠️  SOME CHECKS FAILED - PLEASE INVESTIGATE  ⚠️      ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Troubleshooting tips:"
    echo "1. Check Docker logs: docker-compose logs -f"
    echo "2. Restart services: docker-compose restart"
    echo "3. Check port conflicts: sudo netstat -tulpn"
    exit 1
fi
