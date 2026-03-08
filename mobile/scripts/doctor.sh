#!/usr/bin/env bash
# =============================================================
# eGranja Mobile - Diagnostico de Pre-requisitos
# =============================================================

set -uo pipefail

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_ok() {
  echo -e "  ${GREEN}OK${NC} $1"
  PASS=$((PASS + 1))
}

check_fail() {
  echo -e "  ${RED}FALHOU${NC} $1"
  FAIL=$((FAIL + 1))
}

check_warn() {
  echo -e "  ${YELLOW}AVISO${NC} $1"
  WARN=$((WARN + 1))
}

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  eGranja Mobile - Diagnostico         ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ---- Node.js ----
echo -e "${BLUE}Ambiente Node:${NC}"
if command -v node >/dev/null 2>&1; then
  NODE_V=$(node -v | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_V" | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 20 ]; then
    check_ok "Node.js v$NODE_V (>= 20)"
  else
    check_fail "Node.js v$NODE_V (precisa >= 20)"
  fi
else
  check_fail "Node.js nao encontrado"
fi

if command -v npm >/dev/null 2>&1; then
  check_ok "npm $(npm -v)"
else
  check_fail "npm nao encontrado"
fi

if command -v npx >/dev/null 2>&1; then
  check_ok "npx disponivel"
else
  check_fail "npx nao encontrado"
fi

# ---- Expo ----
echo ""
echo -e "${BLUE}Expo:${NC}"
if npx expo --version >/dev/null 2>&1; then
  check_ok "Expo CLI $(npx expo --version 2>/dev/null)"
else
  check_fail "Expo CLI nao encontrado (npm install -g expo-cli)"
fi

if command -v eas >/dev/null 2>&1; then
  check_ok "EAS CLI $(eas --version 2>/dev/null)"
else
  check_warn "EAS CLI nao encontrado (npm install -g eas-cli) - opcional para builds na nuvem"
fi

# ---- Android ----
echo ""
echo -e "${BLUE}Android:${NC}"
if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
  check_ok "ANDROID_HOME=$ANDROID_HOME"
else
  check_fail "ANDROID_HOME nao definido ou diretorio nao existe"
fi

if command -v java >/dev/null 2>&1; then
  JAVA_V=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
  check_ok "Java JDK $JAVA_V"
else
  check_fail "Java JDK nao encontrado (instale JDK 17+)"
fi

if command -v adb >/dev/null 2>&1; then
  check_ok "ADB $(adb version 2>/dev/null | head -1 | awk '{print $NF}')"
elif [ -n "${ANDROID_HOME:-}" ] && [ -x "$ANDROID_HOME/platform-tools/adb" ]; then
  check_ok "ADB (via ANDROID_HOME)"
else
  check_fail "ADB nao encontrado"
fi

if [ -n "${ANDROID_HOME:-}" ] && [ -x "$ANDROID_HOME/emulator/emulator" ]; then
  AVDS=$("$ANDROID_HOME/emulator/emulator" -list-avds 2>/dev/null | wc -l)
  if [ "$AVDS" -gt 0 ]; then
    check_ok "Emulador Android ($AVDS AVD(s) disponivel(is))"
  else
    check_warn "Emulador Android instalado mas nenhum AVD criado (make emulator-create)"
  fi
else
  check_fail "Emulador Android nao encontrado"
fi

# ---- Docker ----
echo ""
echo -e "${BLUE}Docker (infraestrutura):${NC}"
if command -v docker >/dev/null 2>&1; then
  check_ok "Docker $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
else
  check_warn "Docker nao encontrado (necessario para make infra-up)"
fi

if docker compose version >/dev/null 2>&1; then
  check_ok "Docker Compose $(docker compose version 2>/dev/null | awk '{print $NF}')"
else
  check_warn "Docker Compose nao encontrado"
fi

# ---- macOS apenas ----
if [ "$(uname)" = "Darwin" ]; then
  echo ""
  echo -e "${BLUE}iOS (macOS):${NC}"
  if command -v xcodebuild >/dev/null 2>&1; then
    check_ok "Xcode $(xcodebuild -version 2>/dev/null | head -1 | awk '{print $2}')"
  else
    check_warn "Xcode nao encontrado (necessario para builds iOS)"
  fi
fi

# ---- Resumo ----
echo ""
echo -e "${BLUE}========================================${NC}"
TOTAL=$((PASS + FAIL + WARN))
echo -e "  Resultado: ${GREEN}$PASS OK${NC} / ${RED}$FAIL falhas${NC} / ${YELLOW}$WARN avisos${NC} (de $TOTAL verificacoes)"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${YELLOW}Dica: Itens com FALHOU impedem builds locais.${NC}"
  echo -e "${YELLOW}Use 'make build-apk' para builds na nuvem (EAS) sem precisar do Android SDK local.${NC}"
  echo ""
fi
