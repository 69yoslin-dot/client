#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#  INSTALADOR OFICIAL - SS_MADARAS VIP (v2.0)
# ==========================================

# COLORES
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
P='\033[1;35m'
NC='\033[0m'

clear
echo -e "${P}==========================================${NC}"
echo -e "${W}      🦊 SS_MADARAS VIP - GSO MOD 🦊     ${NC}"
echo -e "${P}==========================================${NC}"

# 1. Verificar Entorno
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${R}[!] Error:${NC} Solo funciona en Termux."
    exit 1
fi

# 2. Reparar Repositorios y Dependencias
echo -e "${Y}[*] Preparando entorno de red...${NC}"
pkg update -y && pkg upgrade -y
pkg install wget curl procps dnsutils -y > /dev/null 2>&1

# 3. Descargar Cliente (Binario Slipstream)
CLIENT_URL="https://github.com/69yoslin-dot/client/raw/main/slipstream-client-android"
CLIENT_BIN="slipstream-client"

echo -e "${Y}[*] Instalando motor VIP (Protocolo DNS-QUIC)...${NC}"
pkill -f $CLIENT_BIN 2>/dev/null # Limpiar procesos viejos
wget -O $CLIENT_BIN $CLIENT_URL -q --show-progress

if [ -f "$CLIENT_BIN" ]; then
    chmod +x $CLIENT_BIN
else
    echo -e "${R}[!] Error: No se pudo descargar el motor.${NC}"
    exit 1
fi

# 4. Descargar Menú con el "Truco ETECSA"
MENU_URL="https://github.com/69yoslin-dot/client/raw/main/menu.sh"
echo -e "${Y}[*] Sincronizando panel de control...${NC}"
wget -O menu.sh $MENU_URL -q
chmod +x menu.sh

mkdir -p "$HOME/.slipstream"

echo -e "\n${G}✅ INSTALACIÓN COMPLETADA CON ÉXITO${NC}"
echo -e "${W} Inicia con:${NC} ${Y}./menu.sh${NC}\n"
