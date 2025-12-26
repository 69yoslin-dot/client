#!/data/data/com.termux/files/usr/bin/bash

# --- ENLACE AL SETUP EN TU REPO ---
URL_SETUP="https://raw.githubusercontent.com/69yoslin-dot/client/main/setup.sh"
# ----------------------------------

clear
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m       INSTALADOR SS.MADARAS VIP        \e[0m"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

# 1. Reparar posibles errores de librerías primero
echo -e "\e[1;32m[*] Verificando integridad del sistema...\e[0m"
pkg install openssl termux-tools -y > /dev/null 2>&1

# 2. Instalar dependencias
echo -e "\e[1;32m[*] Instalando herramientas...\e[0m"
pkg install wget brotli openssl-tool iproute2 -y > /dev/null 2>&1

# 3. Descargar Cliente Binario
echo -e "\e[1;32m[*] Descargando núcleo del sistema...\e[0m"
# Usamos -k por si hay problemas con certificados SSL en Termux viejos
wget -q -k -O slipstream-client https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
chmod +x slipstream-client

# 4. Descargar el Menú de Conexión (Tu script)
echo -e "\e[1;32m[*] Configurando menú de acceso...\e[0m"
wget -q -k -O setup.sh "$URL_SETUP" 
chmod +x setup.sh

# 5. Crear acceso directo
echo "bash setup.sh" > start
chmod +x start

# Intentar ejecutar el menú automáticamente al terminar
clear
if [ -f "setup.sh" ]; then
    echo -e "\e[1;32m¡Instalación exitosa!\e[0m"
    sleep 1
    bash setup.sh
else
    echo -e "\e[1;31m[!] Error: No se pudo descargar el archivo de configuración.\e[0m"
    echo -e "Reintenta la instalación."
fi
