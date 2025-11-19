#!/bin/bash

# TeamFlow - Start Script
# Inicia todos os serviços do TeamFlow

set -e

echo "🚀 TeamFlow - Starting Services"
echo "================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar se uma porta está em uso
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0
    else
        return 1
    fi
}

# Função para matar processo em uma porta
kill_port() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$pid" ]; then
        echo -e "${YELLOW}⚠️  Killing process on port $port (PID: $pid)${NC}"
        kill -9 $pid 2>/dev/null || true
        sleep 1
    fi
}

# Verificar se pnpm está instalado
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}❌ pnpm não encontrado. Instale com: npm install -g pnpm${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Verificando dependências...${NC}"
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠️  node_modules não encontrado. Instalando dependências...${NC}"
    pnpm install
fi

# Verificar Docker (opcional)
echo ""
echo -e "${BLUE}🐳 Verificando Docker...${NC}"
if command -v docker &> /dev/null && docker info &> /dev/null; then
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}✅ Serviços Docker rodando${NC}"
    else
        echo -e "${YELLOW}⚠️  Iniciando serviços Docker (Postgres, Redis, RabbitMQ)...${NC}"
        docker-compose up -d
        sleep 3
    fi
else
    echo -e "${YELLOW}⚠️  Docker não disponível. Pulando infraestrutura.${NC}"
fi

# Verificar e limpar portas se necessário
echo ""
echo -e "${BLUE}🔍 Verificando portas...${NC}"

if check_port 3000; then
    echo -e "${YELLOW}⚠️  Porta 3000 (Gateway) já em uso${NC}"
    read -p "Deseja matar o processo? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill_port 3000
    fi
fi

if check_port 3001; then
    echo -e "${YELLOW}⚠️  Porta 3001 (Auth) já em uso${NC}"
    read -p "Deseja matar o processo? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill_port 3001
    fi
fi

if check_port 5173; then
    echo -e "${YELLOW}⚠️  Porta 5173 (Web) já em uso${NC}"
    read -p "Deseja matar o processo? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill_port 5173
    fi
fi

# Build dos serviços (se necessário)
echo ""
echo -e "${BLUE}🔨 Verificando builds...${NC}"

if [ ! -d "apps/apis/auth/dist" ]; then
    echo -e "${YELLOW}⚠️  Building Auth Service...${NC}"
    cd apps/apis/auth && pnpm build && cd ../../..
fi

if [ ! -d "apps/apis/gateway/dist" ]; then
    echo -e "${YELLOW}⚠️  Building Gateway Service...${NC}"
    cd apps/apis/gateway && pnpm build && cd ../../..
fi

echo -e "${GREEN}✅ Builds prontos${NC}"

# Iniciar serviços
echo ""
echo -e "${BLUE}🚀 Iniciando serviços...${NC}"
echo ""

# Criar diretório de logs
mkdir -p logs

# Auth Service
echo -e "${GREEN}▶️  Starting Auth Service (Port 3001)...${NC}"
cd apps/apis/auth
PORT=3001 node dist/main.js > ../../../logs/auth.log 2>&1 &
AUTH_PID=$!
cd ../../..
sleep 2

# Verificar se Auth iniciou
if check_port 3001; then
    echo -e "${GREEN}✅ Auth Service rodando (PID: $AUTH_PID)${NC}"
else
    echo -e "${RED}❌ Auth Service falhou ao iniciar. Verifique logs/auth.log${NC}"
    cat logs/auth.log
fi

# Gateway Service
echo -e "${GREEN}▶️  Starting Gateway Service (Port 3000)...${NC}"
cd apps/apis/gateway
PORT=3000 node dist/main.js > ../../../logs/gateway.log 2>&1 &
GATEWAY_PID=$!
cd ../../..
sleep 2

# Verificar se Gateway iniciou
if check_port 3000; then
    echo -e "${GREEN}✅ Gateway Service rodando (PID: $GATEWAY_PID)${NC}"
else
    echo -e "${RED}❌ Gateway Service falhou ao iniciar. Verifique logs/gateway.log${NC}"
    cat logs/gateway.log
fi

# Web (opcional - comentado por padrão)
# echo -e "${GREEN}▶️  Starting Web Frontend (Port 5173)...${NC}"
# cd apps/web
# pnpm dev > ../../logs/web.log 2>&1 &
# WEB_PID=$!
# cd ../..

# Resumo
echo ""
echo "================================"
echo -e "${GREEN}🎉 TeamFlow Services Started!${NC}"
echo "================================"
echo ""
echo -e "${BLUE}📍 Services:${NC}"
echo -e "  Auth:    http://localhost:3001 (PID: $AUTH_PID)"
echo -e "  Gateway: http://localhost:3000 (PID: $GATEWAY_PID)"
# echo -e "  Web:     http://localhost:5173 (PID: $WEB_PID)"
echo ""
echo -e "${BLUE}📊 Health Checks:${NC}"
sleep 1
AUTH_STATUS=$(curl -s http://localhost:3001/health 2>/dev/null | grep -o '"status":"ok"' && echo "✅" || echo "❌")
GATEWAY_STATUS=$(curl -s http://localhost:3000/health 2>/dev/null | grep -o '"status":"ok"' && echo "✅" || echo "❌")
echo -e "  Auth:    $AUTH_STATUS"
echo -e "  Gateway: $GATEWAY_STATUS"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "  Swagger Auth:    http://localhost:3001/docs"
echo -e "  Swagger Gateway: http://localhost:3000/docs"
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "  Auth:    tail -f logs/auth.log"
echo -e "  Gateway: tail -f logs/gateway.log"
echo ""
echo -e "${YELLOW}💡 Para parar os serviços:${NC}"
echo -e "  kill $AUTH_PID $GATEWAY_PID"
echo -e "  ou execute: ./scripts/stop.sh"
echo ""

# Salvar PIDs para script de stop
echo "$AUTH_PID" > logs/auth.pid
echo "$GATEWAY_PID" > logs/gateway.pid
# echo "$WEB_PID" > logs/web.pid

echo -e "${GREEN}✨ Pronto para desenvolvimento!${NC}"

