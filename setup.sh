#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#  INSTALADOR OFICIAL - SS_MADARAS
# ==========================================

# COLORES
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
P='\033[1;35m' # Purple
NC='\033[0m'

clear
echo -e "${P}==========================================${NC}"
echo -e "${W}         🦊 SS_MADARAS VIP 🦊            ${NC}"
echo -e "${P}==========================================${NC}"
echo -e "${C}      Canal: @internet_gratis_canal       ${NC}"
echo ""

# 1. Verificar Entorno
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${R}[!] Error:${NC} Solo funciona en Termux."
    exit 1
fi

# 2. Instalar Dependencias
echo -e "${Y}[*] Preparando sistema...${NC}"
pkg update -y > /dev/null 2>&1
pkg install wget curl figlet -y > /dev/null 2>&1

# 3. Descargar Cliente
# ¡OJO! CAMBIA ESTE LINK POR EL TUYO DE GITHUB (El raw del archivo compilado)
CLIENT_URL="https://github.com/69yoslin-dot/client/raw/main/slipstream-client-android"
CLIENT_BIN="slipstream-client"

echo -e "${Y}[*] Instalando motor VIP...${NC}"
wget -O $CLIENT_BIN $CLIENT_URL -q --show-progress

if [ -f "$CLIENT_BIN" ]; then
    chmod +x $CLIENT_BIN
else
    echo -e "${R}[!] Error de descarga. Revisa tu internet.${NC}"
    exit 1
fi

# 4. Descargar Menu
# CAMBIA ESTE LINK POR EL TUYO DE GITHUB (El raw de menu.sh)
MENU_URL="https://github.com/69yoslin-dot/client/raw/main/menu.sh"
wget -O menu.sh $MENU_URL -q
chmod +x menu.sh

echo ""
echo -e "${G}✅ INSTALACIÓN COMPLETADA${NC}"
echo -e "${W}Escribe ${Y}./menu.sh${W} y pulsa ENTER.${NC}"
echo ""
