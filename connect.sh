#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CLIENTE PREMIUM SS.MADARAS
# ==========================================

# Configuración del Servidor
DOMAIN="freezing.2bd.net"
# Puerto local del cliente (para conectar apps como Injector o Custom)
LOCAL_PORT="5201" 

# Colores y Estilos
PURPLE='\033[38;5;93m'
CYAN='\033[38;5;51m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;226m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

# Directorio de logs
LOG_FILE="$HOME/.ss_madaras.log"

# Lista de DNS (ETECSA y otros funcionales en la isla)
DNS_SERVERS=(
"200.55.128.130"
"200.55.128.140"
"181.225.231.120"
"181.225.231.110"
)

# Funciones Visuales
banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo " █▀ █▀   █▀▄▀█ ▄▀█ █▀▄ ▄▀█ █▀█ ▄▀█ █▀"
    echo " ▄█ ▄█   █░▀░█ █▀█ █▄▀ █▀█ █▀▄ █▀█ ▄█"
    echo -e "${CYAN}    >>> PRIVATE SERVER: FREEZING <<<${RESET}"
    echo -e "${PURPLE} ────────────────────────────────────────${RESET}"
    echo -e "${WHITE}  Dominio: ${GREEN}$DOMAIN${RESET}"
    echo -e "${WHITE}  Telegram: ${CYAN}t.me/ss_madaras${RESET}"
    echo -e "${PURPLE} ────────────────────────────────────────${RESET}"
}

clean_process() {
    pkill -f slipstream-client > /dev/null 2>&1
}

connect() {
    clean_process
    echo -e "\n${YELLOW}[*] Iniciando motor de inyección...${RESET}"
    
    # Selecciona un DNS aleatorio de la lista para balancear carga
    RANDOM_DNS=${DNS_SERVERS[$RANDOM % ${#DNS_SERVERS[@]}]}
    
    echo -e "${CYAN}[*] Apuntando a DNS: ${WHITE}$RANDOM_DNS${RESET}"
    echo -e "${CYAN}[*] Estableciendo túnel hacia: ${WHITE}$DOMAIN${RESET}"

    # Ejecución del cliente
    ./slipstream-client \
        --tcp-listen-port=$LOCAL_PORT \
        --resolver="$RANDOM_DNS" \
        --domain="$DOMAIN" \
        --keep-alive-interval=30 \
        --congestion-control=cubic \
        > "$LOG_FILE" 2>&1 &

    PID=$!
    sleep 3

    # Verificación simple
    if ps -p $PID > /dev/null; then
        echo -e "\n${GREEN}[✓] CONEXIÓN ESTABLECIDA EXITOSAMENTE${RESET}"
        echo -e "${WHITE}    Puerto Local Abierto: ${YELLOW}$LOCAL_PORT${RESET}"
        echo -e "${WHITE}    Mantén esta terminal abierta.${RESET}"
        echo -e "\n${RED}[!] Presiona CTRL + C para desconectar.${RESET}"
        
        # Bucle para mantener vivo el script visualmente
        while ps -p $PID > /dev/null; do
            sleep 5
        done
    else
        echo -e "\n${RED}[X] FALLO DE CONEXIÓN.${RESET}"
        echo -e "${YELLOW}    Verifica tu red o intenta de nuevo.${RESET}"
        cat "$LOG_FILE"
    fi
}

# Menú Principal
while true; do
    banner
    echo -e "${WHITE} [1] ${GREEN}●${RESET} CONECTAR (Auto DNS)"
    echo -e "${WHITE} [2] ${CYAN}●${RESET} Canal Telegram"
    echo -e "${WHITE} [3] ${RED}●${RESET} Salir"
    echo -e ""
    read -p " Selecciona una opción [1-3]: " option

    case $option in
        1) 
            connect 
            read -p "Presiona Enter para volver..." 
            ;;
        2) 
            termux-open-url "https://t.me/internet_gratis_canal"
            ;;
        3) 
            clean_process
            clear
            exit 0 
            ;;
        *) 
            echo "Opción inválida" 
            sleep 1 
            ;;
    esac
done
