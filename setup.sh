#!/data/data/com.termux/files/usr/bin/bash

# COLORES
CYAN='\033[1;36m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
RESET='\033[0m'

clear
echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════╗"
echo "║      SS.MADARAS INSTALLER v2.0        ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${CYAN}[*] Comprobando entorno Termux...${RESET}"
pkg update -y && pkg upgrade -y

echo -e "${CYAN}[*] Instalando Python3 y dependencias...${RESET}"
pkg install python -y
pip install dnslib requests

echo -e "${CYAN}[*] Descargando Cliente Premium...${RESET}"
# Asegúrate de que el nombre del archivo abajo coincida con como lo subas a GitHub
wget -O client.py https://raw.githubusercontent.com/69yoslin-dot/client/main/client.py

echo -e "${GREEN}[✓] Instalación Completada.${RESET}"
echo -e "${PURPLE}Ejecuta: python client.py${RESET}"
chmod +x client.py
