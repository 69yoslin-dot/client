#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#  INSTALADOR OFICIAL - SS_MADARAS VIP
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
echo -e "${W}         🦊 SS_MADARAS VIP 🦊            ${NC}"
echo -e "${P}==========================================${NC}"
echo -e "${C}      Canal: @internet_gratis_canal       ${NC}"
echo ""

# 1. Verificar Entorno
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${R}[!] Error:${NC} Solo funciona en Termux."
    exit 1
fi

# 2. Reparar Repositorios y Dependencias (Arreglo para evitar el error de librerías)
echo -e "${Y}[*] Actualizando librerías base...${NC}"
pkg update -y && pkg upgrade -y
pkg install wget curl procps libandroid-posix-semaphore libuuid -y > /dev/null 2>&1

# 3. Descargar Cliente (Motor Binario)
# Este es el link directo a tu motor
CLIENT_URL="https://github.com/69yoslin-dot/client/raw/main/slipstream-client-android"
CLIENT_BIN="slipstream-client"

echo -e "${Y}[*] Instalando motor VIP (DNS-QUIC)...${NC}"
wget -O $CLIENT_BIN $CLIENT_URL -q --show-progress

if [ -f "$CLIENT_BIN" ]; then
    chmod +x $CLIENT_BIN
else
    echo -e "${R}[!] Error crítico: No se pudo descargar el motor.${NC}"
    exit 1
fi

# 4. Descargar Menú Ético
MENU_URL="https://github.com/69yoslin-dot/client/raw/main/menu.sh"
echo -e "${Y}[*] Configurando panel de control...${NC}"
wget -O menu.sh $MENU_URL -q

if [ -f "menu.sh" ]; then
    chmod +x menu.sh
else
    echo -e "${R}[!] Error al descargar el menú.${NC}"
    exit 1
fi

# 5. Limpieza y Finalización
# Creamos la carpeta de logs para que el menú ético pueda trabajar
mkdir -p "$HOME/.slipstream"

echo ""
echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${G}       ✅ INSTALACIÓN COMPLETADA         ${NC}"
echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${W} Para iniciar, escribe:${NC}"
echo -e "${Y} ./menu.sh${NC}"
echo ""
