#!/bin/bash

# TeamFlow - Test Runner Script
# Executa diferentes tipos de testes

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para exibir menu
show_menu() {
    echo ""
    echo -e "${BLUE}🧪 TeamFlow - Test Runner${NC}"
    echo "=========================="
    echo ""
    echo "1) Rodar todos os testes"
    echo "2) Rodar testes unitários"
    echo "3) Rodar testes E2E"
    echo "4) Rodar testes com coverage"
    echo "5) Rodar testes em watch mode"
    echo "6) Rodar testes do Auth service"
    echo "7) Rodar testes do Gateway service"
    echo "8) Ver coverage report"
    echo "9) Limpar coverage"
    echo "0) Sair"
    echo ""
    read -p "Escolha uma opção: " choice
}

# Função para rodar todos os testes
run_all_tests() {
    echo -e "${BLUE}🧪 Rodando todos os testes...${NC}"
    pnpm test
    echo -e "${GREEN}✅ Testes concluídos!${NC}"
}

# Função para rodar testes unitários
run_unit_tests() {
    echo -e "${BLUE}📝 Rodando testes unitários...${NC}"
    pnpm test --testPathIgnorePatterns=e2e
    echo -e "${GREEN}✅ Testes unitários concluídos!${NC}"
}

# Função para rodar testes E2E
run_e2e_tests() {
    echo -e "${BLUE}🚀 Rodando testes E2E...${NC}"
    pnpm test:e2e
    echo -e "${GREEN}✅ Testes E2E concluídos!${NC}"
}

# Função para rodar com coverage
run_coverage() {
    echo -e "${BLUE}📊 Rodando testes com coverage...${NC}"
    pnpm test:cov
    echo ""
    echo -e "${YELLOW}📁 Coverage reports gerados em:${NC}"
    echo "  - apps/apis/auth/coverage/"
    echo "  - apps/apis/gateway/coverage/"
    echo ""
    read -p "Deseja abrir o report no browser? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "apps/apis/auth/coverage/index.html" ]; then
            open apps/apis/auth/coverage/index.html
        fi
    fi
    echo -e "${GREEN}✅ Coverage concluído!${NC}"
}

# Função para watch mode
run_watch() {
    echo -e "${BLUE}👀 Rodando testes em watch mode...${NC}"
    echo -e "${YELLOW}Pressione 'q' para sair${NC}"
    pnpm test:watch
}

# Função para testes do auth
run_auth_tests() {
    echo -e "${BLUE}🔐 Rodando testes do Auth service...${NC}"
    pnpm test:auth
    echo -e "${GREEN}✅ Testes do Auth concluídos!${NC}"
}

# Função para testes do gateway
run_gateway_tests() {
    echo -e "${BLUE}🌐 Rodando testes do Gateway service...${NC}"
    pnpm test:gateway
    echo -e "${GREEN}✅ Testes do Gateway concluídos!${NC}"
}

# Função para ver coverage
view_coverage() {
    echo -e "${BLUE}📊 Abrindo coverage reports...${NC}"
    if [ -f "apps/apis/auth/coverage/index.html" ]; then
        open apps/apis/auth/coverage/index.html
        echo -e "${GREEN}✅ Auth coverage aberto!${NC}"
    else
        echo -e "${RED}❌ Coverage não encontrado. Execute 'pnpm test:cov' primeiro.${NC}"
    fi

    if [ -f "apps/apis/gateway/coverage/index.html" ]; then
        open apps/apis/gateway/coverage/index.html
        echo -e "${GREEN}✅ Gateway coverage aberto!${NC}"
    fi
}

# Função para limpar coverage
clean_coverage() {
    echo -e "${YELLOW}🗑️  Limpando coverage...${NC}"
    rm -rf apps/apis/auth/coverage
    rm -rf apps/apis/gateway/coverage
    echo -e "${GREEN}✅ Coverage limpo!${NC}"
}

# Loop principal
while true; do
    show_menu
    case $choice in
        1)
            run_all_tests
            read -p "Pressione Enter para continuar..."
            ;;
        2)
            run_unit_tests
            read -p "Pressione Enter para continuar..."
            ;;
        3)
            run_e2e_tests
            read -p "Pressione Enter para continuar..."
            ;;
        4)
            run_coverage
            read -p "Pressione Enter para continuar..."
            ;;
        5)
            run_watch
            ;;
        6)
            run_auth_tests
            read -p "Pressione Enter para continuar..."
            ;;
        7)
            run_gateway_tests
            read -p "Pressione Enter para continuar..."
            ;;
        8)
            view_coverage
            read -p "Pressione Enter para continuar..."
            ;;
        9)
            clean_coverage
            read -p "Pressione Enter para continuar..."
            ;;
        0)
            echo -e "${GREEN}👋 Até logo!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opção inválida!${NC}"
            read -p "Pressione Enter para continuar..."
            ;;
    esac
done

