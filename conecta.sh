#!/data/data/com.termux/files/usr/bin/bash

# ==================================================
#  SS.MADARAS CLIENT - FREEZING DNS (Premium Edition)
#  Basado en Lógica v1.0.8-MOD | 100% Automático
# ==================================================

# --- CONFIGURACIÓN ---
DOMAIN="dns.madaras.work.gd"
LOCAL_PORT="5201"
# URL del binario (Usamos el repo de Mahboub que es estable, o puedes poner el tuyo)
BIN_URL="https://github.com/Mahboub-power-is-back/quic_over_dns/raw/main/slipstream-client"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
mkdir -p "$LOG_DIR"

# SERVIDORES ETECSA / WIFI
DATA_SERVERS=("200.55.128.130:53" "200.55.128.140:53" "200.55.128.230:53" "200.55.128.250:53")
WIFI_SERVERS=("181.225.231.120:53" "181.225.231.110:53" "181.225.233.40:53" "181.225.233.30:53")

# --- COLORES PREMIUM ---
PURPLE='\033[38;5;93m'
CYAN='\033[38;5;51m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;226m'
GREY='\033[38;5;240m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

# --- FUNCIONES ---

banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo " ╔══════════════════════════════════════════╗"
    echo " ║       SS.MADARAS | FREEZING SERVER       ║"
    echo " ╚══════════════════════════════════════════╝"
    echo -e "${CYAN}  » Dominio : ${WHITE}$DOMAIN"
    echo -e "${CYAN}  » Versión : ${WHITE}1.0.8-MOD PRO"
    echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
}

check_binary() {
    if [ ! -f "./slipstream-client" ]; then
        echo -e "${YELLOW}[!] Descargando núcleo del sistema...${RESET}"
        # Intentamos descargar. Si falla, avisamos.
        wget -q --show-progress -L "$BIN_URL" -O slipstream-client
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ERROR] No se pudo descargar el binario. Verifica tu internet.${RESET}"
            exit 1
        fi
        chmod +x slipstream-client
        echo -e "${GREEN}[OK] Núcleo instalado.${RESET}"
        sleep 1
    fi
}

clean_slipstream() {
    pkill -f slipstream-client > /dev/null 2>&1
    sleep 1
}

check_server_on_start() {
    check_binary
    clean_slipstream
    > "$LOG_FILE"
    
    echo -e "${GREY}Verificando estado del servidor...${RESET}"
    ./slipstream-client --tcp-listen-port=$LOCAL_PORT --resolver=1.1.1.1:53 --domain="$DOMAIN" --keep-alive-interval=600 --congestion-control=cubic > "$LOG_FILE" 2>&1 &
    
    PID=$!
    SERVER_STATUS="INACTIVO"
    for i in {1..8}; do
        if grep -q "Connection confirmed" "$LOG_FILE"; then SERVER_STATUS="ACTIVO"; break; fi
        if grep -q "Connection closed" "$LOG_FILE"; then break; fi
        if kill -0 $PID 2>/dev/null && [ $i -ge 6 ]; then SERVER_STATUS="ACTIVO"; break; fi
        sleep 1
    done
    kill $PID 2>/dev/null
    clean_slipstream
}

show_server_status() {
    if [ "$SERVER_STATUS" = "ACTIVO" ]; then
        echo -e " Estado del Servidor: ${GREEN}${BOLD}ACTIVO ✅${RESET}"
    else
        echo -e " Estado del Servidor: ${RED}${BOLD}INACTIVO ❌${RESET}"
    fi
}

connect_auto() {
    local SERVERS=("$@")
    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"
        banner
        echo -e "${YELLOW}[!] INICIANDO PROTOCOLO DE CONEXIÓN...${RESET}"
        echo -e "${WHITE}Probando nodo: ${CYAN}$SERVER${RESET}"
        
        ./slipstream-client --tcp-listen-port=$LOCAL_PORT --resolver="$SERVER" --domain="$DOMAIN" --keep-alive-interval=600 --congestion-control=cubic > >(tee -a "$LOG_FILE") 2>&1 &
        
        PID=$!
        for i in {1..5}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                clear
                banner
                echo -e "${GREEN}${BOLD} [✓] CONEXIÓN ESTABLECIDA EXITOSAMENTE${RESET}"
                echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
                echo -e "${WHITE} » DNS Activo : ${GREEN}$SERVER${RESET}"
                echo -e "${WHITE} » Puerto     : ${YELLOW}$LOCAL_PORT${RESET}"
                echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
                echo -e "${YELLOW}Abra HTTP Custom y conecte a 127.0.0.1:5201${RESET}"
                echo -e "${RED} [!] Presiona CTRL + C para detener${RESET}"
                wait $PID
                return
            fi
            sleep 1
        done
        clean_slipstream
    done
    echo -e "${RED}No se pudo conectar con ningún DNS.${RESET}"
    read -p "ENTER para volver"
}

# --- INICIO ---
# Aseguramos permisos de ejecución al propio script por si acaso
chmod +x "$0"
banner
check_server_on_start

while true; do
    banner
    show_server_status
    echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
    echo -e " ${WHITE}[1]${RESET} Conectar vía ${YELLOW}DATOS MÓVILES${RESET}"
    echo -e " ${WHITE}[2]${RESET} Conectar vía ${GREEN}WIFI / ETECSA${RESET}"
    echo -e " ${WHITE}[0]${RESET} SALIR"
    echo -e ""
    read -p " Selecciona una opción: " opt
    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        0) clear; exit 0 ;;
    esac
done
