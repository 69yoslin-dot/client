#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  INSTALADOR OFICIAL SS_MADARAS - SLIPSTREAM
# ==========================================

clear
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# --- COLORES Y VARIABLES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- COMPROBAR ENTORNO TERMUX ---
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[!] Este script solo funciona en Termux Android.${NC}"
    exit 1
fi

# --- INSTALACIÓN DE DIALOG (INTERFAZ) ---
echo -e "${CYAN}[*] Verificando dependencias UI...${NC}"
if ! command -v dialog >/dev/null 2>&1; then
    pkg update -y >/dev/null 2>&1
    pkg install dialog -y >/dev/null 2>&1
fi

MODE="DIALOG"

# --- FUNCIONES DE INTERFAZ ---
msg() {
    dialog --backtitle "SS_MADARAS INSTALLER" --title "Información" --msgbox "$1" 10 55
}

confirm() {
    dialog --backtitle "SS_MADARAS INSTALLER" --title "Confirmación" --yesno "$1" 8 45
    return $?
}

# --- BIENVENIDA ---
dialog --backtitle "SS_MADARAS | INTERNET GRATIS" \
--title "BIENVENIDO" \
--msgbox "Bienvenido al instalador del Servidor Privado de SS_MADARAS.\n\nSe instalarán los recursos necesarios para conectar al servidor DNS High-Speed.\n\nTelegram: @ss_madaras" 12 60

confirm "¿Deseas iniciar la instalación?"
[ $? -ne 0 ] && clear && echo "Instalación cancelada." && exit 1

# --- ACTUALIZAR REPOSITORIOS ---
dialog --infobox "Optimizando repositorios de Termux...\nEsto puede tardar unos segundos." 5 50
termux-change-repo >/dev/null 2>&1
pkg update -y >/dev/null 2>&1

# --- FUNCIÓN DE INSTALACIÓN CON BARRA DE PROGRESO ---
install_process() {
    # 1. Actualización base
    echo 10
    pkg upgrade -y >/dev/null 2>&1
    
    # 2. Instalar herramientas
    echo 30
    pkg install wget brotli openssl termux-tools dos2unix -y >/dev/null 2>&1

    # 3. Descargar el Cliente Slipstream (Binario)
    echo 50
    # Usamos el mismo binario compatible con el servidor Mahboub
    wget -q -O $PREFIX/bin/slipstream-client https://github.com/Mahboub-power-is-back/quic_over_dns/raw/main/slipstream-client
    chmod +x $PREFIX/bin/slipstream-client

    # 4. Descargar el script de conexión (install-client.sh renombrado a connect.sh para el usuario)
    echo 75
    # NOTA: Ajusta esta URL si el nombre en tu repo es diferente, aquí asumo que subirás el segundo script como install-client.sh
    wget -q -O $HOME/connect.sh https://raw.githubusercontent.com/69yoslin-dot/client/main/install-client.sh
    chmod +x $HOME/connect.sh

    echo 100
    sleep 1
}

# Ejecutar instalación
install_process | dialog --backtitle "SS_MADARAS INSTALLER" --title "Instalando..." --gauge "Descargando recursos y configurando binarios..." 10 60 0

# --- MENSAJE FINAL ---
TELEGRAM_CHAT="https://t.me/ss_madaras"
TELEGRAM_CANAL="https://t.me/internet_gratis_canal"

while true; do
    choice=$(dialog --clear --backtitle "SS_MADARAS TEAM" --title "INSTALACIÓN COMPLETADA" \
        --menu "Todo está listo. Selecciona una opción:" 12 55 3 \
        1 "ABRIR CANAL TELEGRAM" \
        2 "CONTACTAR AL ADMIN" \
        3 "FINALIZAR Y SALIR" 3>&1 1>&2 2>&3)

    case $choice in
        1) am start -a android.intent.action.VIEW -d "$TELEGRAM_CANAL" >/dev/null 2>&1 ;;
        2) am start -a android.intent.action.VIEW -d "$TELEGRAM_CHAT" >/dev/null 2>&1 ;;
        *) break ;;
    esac
done

clear
echo -e "${GREEN}==============================================${NC}"
echo -e "${CYAN} INSTALACIÓN EXITOSA ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "Para iniciar la conexión, escribe el comando:"
echo -e "\n    ${GREEN}./connect.sh${NC}\n"
