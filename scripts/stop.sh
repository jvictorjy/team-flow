#!/bin/bash

# TeamFlow - Stop Script
# Para todos os serviços do TeamFlow

set -e

echo "🛑 TeamFlow - Stopping Services"
echo "================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para matar processo por PID
kill_pid() {
    local pid=$1
    local name=$2
    if [ ! -z "$pid" ] && kill -0 $pid 2>/dev/null; then
        echo -e "${YELLOW}⏹️  Stopping $name (PID: $pid)${NC}"
        kill -15 $pid 2>/dev/null || kill -9 $pid 2>/dev/null
        sleep 1
        if kill -0 $pid 2>/dev/null; then
            echo -e "${RED}❌ Failed to stop $name${NC}"
        else
            echo -e "${GREEN}✅ $name stopped${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  $name not running${NC}"
    fi
}

# Ler PIDs dos arquivos
if [ -f "logs/auth.pid" ]; then
    AUTH_PID=$(cat logs/auth.pid)
    kill_pid $AUTH_PID "Auth Service"
    rm -f logs/auth.pid
fi

if [ -f "logs/gateway.pid" ]; then
    GATEWAY_PID=$(cat logs/gateway.pid)
    kill_pid $GATEWAY_PID "Gateway Service"
    rm -f logs/gateway.pid
fi

if [ -f "logs/web.pid" ]; then
    WEB_PID=$(cat logs/web.pid)
    kill_pid $WEB_PID "Web Frontend"
    rm -f logs/web.pid
fi

# Garantir que as portas estão livres
echo ""
echo -e "${BLUE}🔍 Verificando portas...${NC}"

for port in 3000 3001 5173; do
    PID=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$PID" ]; then
        echo -e "${YELLOW}⚠️  Porta $port ainda em uso (PID: $PID). Matando...${NC}"
        kill -9 $PID 2>/dev/null || true
    fi
done

sleep 1

echo ""
echo -e "${GREEN}✅ Todos os serviços foram parados${NC}"
echo ""

# Limpar logs antigos (opcional)
read -p "Deseja limpar os logs? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f logs/*.log
    echo -e "${GREEN}✅ Logs limpos${NC}"
fi

echo ""
echo -e "${BLUE}💡 Para iniciar novamente:${NC}"
echo -e "  ./scripts/start.sh"
echo ""

