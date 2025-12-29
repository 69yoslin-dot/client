#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  INSTALADOR OFICIAL SS.MADARAS | FREEZING
# ==========================================

# Colores
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
RESET='\033[0m'

clear
echo -e "${PURPLE}"
echo " ╔══════════════════════════════════════╗"
echo " ║     INSTALLER BY SS.MADARAS v2.0     ║"
echo " ╚══════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${CYAN}[*] Verificando entorno Termux...${RESET}"
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[!] Error: Este script solo corre en Termux.${RESET}"
    exit 1
fi
sleep 1

echo -e "${CYAN}[*] Actualizando repositorios...${RESET}"
pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1

echo -e "${CYAN}[*] Instalando dependencias (wget, proot, tools)...${RESET}"
pkg install wget dnsutils termux-tools proot -y > /dev/null 2>&1

echo -e "${CYAN}[*] Descargando cliente Slipstream...${RESET}"
# Asegúrate de que el nombre del archivo en tu github sea slipstream-client
# Reemplaza 'raw.githubusercontent.com' con tu enlace RAW real si cambia
wget -q -O slipstream-client https://raw.githubusercontent.com/69yoslin-dot/client/main/slipstream-client
chmod +x slipstream-client

echo -e "${GREEN}"
echo " ╔══════════════════════════════════════╗"
echo " ║      INSTALACIÓN COMPLETADA          ║"
echo " ║      Ejecuta: ./connect.sh           ║"
echo " ╚══════════════════════════════════════╝"
echo -e "${RESET}"
sleep 2
