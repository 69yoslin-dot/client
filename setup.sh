#!/data/data/com.termux/files/usr/bin/bash

# --- COLORES Y ESTILO ---
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[0m'
B='\033[1;34m'

clear

# --- VERIFICACIÓN DE ENTORNO ---
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${R}[!] Error: Este script es exclusivo para Termux.${W}"
    exit 1
fi

# --- BANNER DE BIENVENIDA ---
echo -e "${B}"
echo "  ███████╗███████╗    ███╗   ███╗ "
echo "  ██╔════╝██╔════╝    ████╗ ████║ "
echo "  ███████╗███████╗    ██╔████╔██║ "
echo "  ╚════██║╚════██║    ██║╚██╔╝██║ "
echo "  ███████║███████║    ██║ ╚═╝ ██║ "
echo "  ╚══════╝╚══════╝    ╚═╝     ╚═╝ "
echo -e "${W}      Instalador Oficial - By SS.MADARAS"
echo ""

echo -e "${C}[*] Preparando instalación VIP...${W}"
sleep 1

# --- CONFIGURACIÓN DE REPOS ---
echo -e "${Y}[!] Configurando repositorios para evitar errores...${W}"
termux-change-repo
pkg update -y > /dev/null 2>&1

# --- INSTALACIÓN DE DEPENDENCIAS ---
echo -e "${G}[+] Instalando paquetes necesarios...${W}"

paquetes=("wget" "brotli" "openssl" "termux-tools" "dos2unix")

for pkg in "${paquetes[@]}"; do
    echo -ne "${Y}    -> Instalando $pkg... ${W}"
    pkg install $pkg -y > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${G}OK${W}"
    else
        echo -e "${R}FALLO${W}"
    fi
done

# --- DESCARGA DEL CLIENTE ---
echo -e "${G}[+] Descargando binarios de conexión...${W}"
wget -q -O slipstream-client https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
chmod +x slipstream-client

# --- DESCARGA DEL MENÚ PRINCIPAL ---
# NOTA: Cambia '69yoslin-dot' si tu usuario es diferente, o asegúrate que el link sea correcto.
echo -e "${G}[+] Descargando interfaz gráfica...${W}"
wget -q -O menu.sh https://raw.githubusercontent.com/69yoslin-dot/client/main/menu.sh
chmod +x menu.sh

# --- FINALIZACIÓN ---
clear
echo -e "${B}"
echo "  ███████╗███████╗    ███╗   ███╗ "
echo "  ██╔════╝██╔════╝    ████╗ ████║ "
echo "  ███████╗███████╗    ██╔████╔██║ "
echo "  ╚════██║╚════██║    ██║╚██╔╝██║ "
echo "  ███████║███████║    ██║ ╚═╝ ██║ "
echo "  ╚══════╝╚══════╝    ╚═╝     ╚═╝ "
echo -e "${W}"
echo -e "${G}   ¡INSTALACIÓN COMPLETADA EXITOSAMENTE! ${W}"
echo -e ""
echo -e "${C}Canal: ${W}https://t.me/internet_gratis_canal"
echo -e "${C}Admin: ${W}https://t.me/ss_madaras"
echo -e ""
echo -e "${Y}Para iniciar, escribe: ${G}./menu.sh${W}"
echo -e ""
