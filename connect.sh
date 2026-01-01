#!/data/data/com.termux/files/usr/bin/bash

# ==================================================
#  SS.MADARAS CLIENT - FREEZING DNS (Premium Edition)
#  Lógica de Conexión: Fidelidad Total Original
# ==================================================

# --- CONFIGURACIÓN DEL SERVIDOR ---
DOMAIN="dns.madaras.work.gd"
LOCAL_PORT="5201"
BIN_URL="https://github.com/Mahboub-power-is-back/quic_over_dns/raw/main/slipstream-client"

# --- LISTAS DE SERVIDORES (Tus datos guardados) ---
DATA_SERVERS=(
"200.55.128.130:53"
"200.55.128.140:53"
"200.55.128.230:53"
"200.55.128.250:53"
)

WIFI_SERVERS=(
"181.225.231.120:53"
"181.225.231.110:53"
"181.225.233.40:53"
"181.225.233.30:53"
)

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

LOG_FILE="$HOME/.ss_madaras.log"
mkdir -p "$HOME/.slipstream"

# --- FUNCIONES DE UTILIDAD ---

banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo " ╔══════════════════════════════════════════╗"
    echo " ║       SS.MADARAS | FREEZING SERVER       ║"
    echo " ╚══════════════════════════════════════════╝"
    echo -e "${CYAN}  » Dominio : ${WHITE}$DOMAIN"
    echo -e "${CYAN}  » Telegram: ${WHITE}t.me/ss_madaras"
    echo -e "${CYAN}  » Canal   : ${WHITE}t.me/internet_gratis_canal"
    echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
}

check_binary() {
    if [ ! -f "./slipstream-client" ]; then
        echo -e "${YELLOW}[!] Descargando Núcleo SS.MADARAS...${RESET}"
        wget -q --show-progress "$BIN_URL" -O slipstream-client
        chmod +x slipstream-client
    fi
}

limpiar_procesos() {
    pkill -f slipstream-client > /dev/null 2>&1
}

verificar_dns_muerto() {
    grep -qE "Connection closed|resolver timeout|no response" "$LOG_FILE"
}

# --- MOTOR DE CONEXIÓN (Lógica Razihel Modificada) ---
conectar_auto() {
    check_binary
    local SERVERS=("$@")
    
    while true; do
        for SERVER in "${SERVERS[@]}"; do
            limpiar_procesos
            > "$LOG_FILE" 

            banner
            echo -e "${YELLOW}[!] INICIANDO PROTOCOLO DE CONEXIÓN...${RESET}"
            echo -e "${GREY}--------------------------------------------${RESET}"
            echo -e "${WHITE}Intentando servidor DNS: ${CYAN}$SERVER${RESET}"
            
            ./slipstream-client \
                --tcp-listen-port=$LOCAL_PORT \
                --resolver="$SERVER" \
                --domain="$DOMAIN" \
                --keep-alive-interval=600 \
                --congestion-control=cubic \
                > >(tee "$LOG_FILE") 2>&1 &
            
            PID=$!
            SERVER_CONNECTED=false

            # Espera optimizada para redes lentas
            echo -e "${GREY}[LOG] Esperando handshake (Máx 15s)...${RESET}"
            for i in {1..15}; do
                if grep -q "Connection confirmed" "$LOG_FILE"; then
                    SERVER_CONNECTED=true
                    ACTIVE_DNS="$SERVER"
                    break
                fi
                sleep 1
            done

            if $SERVER_CONNECTED; then
                clear
                banner
                echo -e "${GREEN}${BOLD} [✓] CONEXIÓN ESTABLECIDA EXITOSAMENTE${RESET}"
                echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
                echo -e "${WHITE} » DNS Activo : ${GREEN}$ACTIVE_DNS${RESET}"
                echo -e "${WHITE} » Puerto     : ${YELLOW}$LOCAL_PORT${RESET}"
                echo -e "${WHITE} » Estado     : ${GREEN}ONLINE${RESET}"
                echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
                echo -e "${GREY} [INFO] Monitoreando estabilidad...${RESET}"
                echo -e "${RED} [!] Presiona CTRL + C para detener${RESET}"

                while true; do
                    if ! kill -0 $PID 2>/dev/null; then break; fi
                    if verificar_dns_muerto; then
                        echo -e "\n${RED}[!] DNS Caído. Reintentando...${RESET}"
                        break
                    fi
                    sleep 2
                done
            else
                echo -e "${RED}[X] Fallo al conectar con $SERVER${RESET}"
                sleep 1
            fi
            limpiar_procesos
        done
        echo -e "\n${YELLOW}[!] Reiniciando ciclo de servidores...${RESET}"
        sleep 1
    done
}

# --- MENÚ PRINCIPAL ---
while true; do
    banner
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && NET_TYPE="${GREEN}WIFI${RESET}" || NET_TYPE="${YELLOW}DATOS${RESET}"

    echo -e " Estado de Red Detectado: $NET_TYPE"
    echo -e "${GREY}--------------------------------------------${RESET}"
    echo -e "${WHITE} [1]${RESET} Conectar vía ${YELLOW}DATOS MÓVILES${RESET}"
    echo -e "${WHITE} [2]${RESET} Conectar vía ${GREEN}WIFI / ETECSA${RESET}"
    echo -e "${WHITE} [3]${RESET} Instalar Dependencias"
    echo -e "${WHITE} [0]${RESET} ${RED}SALIR${RESET}"
    echo -e ""
    read -p " Selecciona una opción: " opt

    case $opt in
        1) conectar_auto "${DATA_SERVERS[@]}" ;;
        2) conectar_auto "${WIFI_SERVERS[@]}" ;;
        3) pkg install wget dnsutils brotli openssl -y ;;
        0) limpiar_procesos; clear; exit 0 ;;
        *) echo "Opción inválida" ;;
    esac
done
