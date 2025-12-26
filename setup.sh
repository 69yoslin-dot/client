#!/data/data/com.termux/files/usr/bin/bash

# --- ENLACE AL SETUP EN TU REPO ---
URL_SETUP="https://raw.githubusercontent.com/69yoslin-dot/client/main/setup.sh"
# ----------------------------------

clear
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m       INSTALADOR SS.MADARAS VIP        \e[0m"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo ""

# 1. Verificar entorno
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "\e[1;31m[!] Error: Este script es solo para Termux.\e[0m"
    exit 1
fi

# 2. Instalar dependencias
echo -e "\e[1;32m[*] Instalando dependencias necesarias...\e[0m"
pkg update -y > /dev/null 2>&1
pkg install wget brotli openssl openssl-tool termux-tools iproute2 -y > /dev/null 2>&1

# 3. Descargar Cliente Binario
echo -e "\e[1;32m[*] Descargando núcleo del sistema...\e[0m"
wget -q -O slipstream-client https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
chmod +x slipstream-client

# 4. Descargar el Menú de Conexión (Tu script)
echo -e "\e[1;32m[*] Configurando menú de acceso...\e[0m"
wget -q -O setup.sh "$URL_SETUP" 
chmod +x setup.sh

# 5. Crear acceso directo simple
echo "bash setup.sh" > start
chmod +x start

echo ""
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;32m      ¡INSTALACIÓN COMPLETADA!          \e[0m"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;37mPara iniciar, escribe:\e[0m \e[1;33m./start\e[0m"
echo ""
