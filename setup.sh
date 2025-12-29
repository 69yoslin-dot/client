#!/data/data/com.termux/files/usr/bin/bash

# COLORES
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
Y='\033[1;33m'
W='\033[0m'

clear
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

banner() {
    clear
    echo -e "${C}=============================================${W}"
    echo -e "${G}         INSTALADOR OFICIAL SS.MADARAS        ${W}"
    echo -e "${C}=============================================${W}"
    echo -e "${Y}   Telegram: https://t.me/ss_madaras${W}"
    echo -e "${Y}   Canal: https://t.me/internet_gratis_canal${W}"
    echo -e "${C}=============================================${W}"
    echo ""
}

### COMPROBAR TERMUX
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${R}[!] Este script solo funciona en Termux.${W}"
    exit 1
fi

banner
echo -e "${Y}[*] Comprobando dependencias...${W}"
pkg update -y >/dev/null 2>&1

packages=("wget" "brotli" "openssl" "termux-tools" "dialog")

for pkg in "${packages[@]}"; do
    if ! command -v $pkg >/dev/null 2>&1; then
        echo -e "${R}[+] Instalando $pkg...${W}"
        pkg install $pkg -y >/dev/null 2>&1
    else
        echo -e "${G}[OK] $pkg ya instalado.${W}"
    fi
done

### DESCARGA DEL CLIENTE
banner
echo -e "${Y}[*] Descargando cliente Slipstream...${W}"

# NOTA PARA EL DUEÑO: Asegúrate de que 'slipstream-client' esté en tu repo
wget -q -O slipstream-client https://raw.githubusercontent.com/69yoslin-dot/client/main/slipstream-client

if [ -f "slipstream-client" ]; then
    chmod +x slipstream-client
    echo -e "${G}[✓] Cliente descargado e instalado correctamente.${W}"
else
    echo -e "${R}[!] Error al descargar el cliente.${W}"
    exit 1
fi

### MENSAJE FINAL
banner
echo -e "${G}¡Instalación Completada!${W}"
echo -e "${C}Ahora ejecuta el script de conexión.${W}"
echo ""
echo -e "${Y}Si necesitas soporte, contacta a SS.MADARAS${W}"
sleep 3
