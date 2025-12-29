#!/data/data/com.termux/files/usr/bin/bash

# ==================================================
#  SS.MADARAS CLIENT - FREEZING DNS (Transparent Mode)
# ==================================================

# --- CONFIGURACIÓN DEL SERVIDOR ---
DOMAIN="freezing.2bd.net"
LOCAL_PORT="5201"

# --- LISTAS DE SERVIDORES (Lógica de Razihel) ---
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

limpiar_procesos() {
    pkill -f slipstream-client > /dev/null 2>&1
}

verificar_dns_muerto() {
    # Busca errores reales en el log para reiniciar si falla
    grep -qE "Connection closed|resolver timeout|no response" "$LOG_FILE"
}

# --- MOTOR DE CONEXIÓN (LÓGICA RAZIHEL) ---
conectar_auto() {
    local SERVERS=("$@")
    local CONNECTED=false
    local INTENTO=0
    
    # Bucle infinito hasta conectar o cancelar
    while true; do
        for SERVER in "${SERVERS[@]}"; do
            limpiar_procesos
            > "$LOG_FILE" # Limpia el log

            banner
            echo -e "${YELLOW}[!] INICIANDO PROTOCOLO DE CONEXIÓN...${RESET}"
            echo -e "${GREY}--------------------------------------------${RESET}"
            echo -e "${WHITE}Intentando servidor DNS: ${CYAN}$SERVER${RESET}"
            
            # EJECUCIÓN DEL CLIENTE (Muestra LOG REAL en segundo plano)
            ./slipstream-client \
                --tcp-listen-port=$LOCAL_PORT \
                --resolver="$SERVER" \
                --domain="$DOMAIN" \
                --keep-alive-interval=600 \
                --congestion-control=cubic \
                > >(tee "$LOG_FILE") 2>&1 &
            
            PID=$!
            SERVER_CONNECTED=false

            # Espera activa de 4 segundos leyendo el log real
            echo -e "${GREY}[LOG] Esperando handshake...${RESET}"
            for i in {1..4}; do
                if grep -q "Connection confirmed" "$LOG_FILE"; then
                    CONNECTED=true
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
                echo -e "${WHITE} » Puerto     : ${YELLOW}$LOCAL_PORT${RESET} (Úsalo en tu VPN)"
                echo -e "${WHITE} » Estado     : ${GREEN}ONLINE${RESET}"
                echo -e "${PURPLE} ────────────────────────────────────────────${RESET}"
                echo -e "${GREY} [INFO] Monitoreando conexión en tiempo real...${RESET}"
                echo -e "${RED} [!] Presiona CTRL + C para desconectar${RESET}"

                # BUCLE DE MONITOREO (Mantiene el script vivo)
                while true; do
                    # Si el proceso muere
                    if ! kill -0 $PID 2>/dev/null; then
                        echo -e "\n${RED}[!] Proceso detenido inesperadamente.${RESET}"
                        break
                    fi
                    # Si el log reporta error
                    if verificar_dns_muerto; then
                        echo -e "\n${RED}[!] El DNS dejó de responder. Reconectando...${RESET}"
                        break
                    fi
                    sleep 2
                done
                # Si sale del while, vuelve a intentar con el siguiente servidor
            else
                echo -e "${RED}[X] Fallo al conectar con $SERVER${RESET}"
                sleep 0.5
            fi
            
            limpiar_procesos
        done
        
        echo -e "\n${YELLOW}[!] Reiniciando lista de servidores...${RESET}"
        sleep 1
    done
}

# --- MENÚ PRINCIPAL ---
while true; do
    banner
    # Detección visual de red (Solo informativa)
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    if [[ "$iface" == wlan* ]]; then
        NET_TYPE="${GREEN}WIFI DETECTADO${RESET}"
    else
        NET_TYPE="${YELLOW}DATOS DETECTADOS${RESET}"
    fi

    echo -e " Estado de Red: $NET_TYPE"
    echo -e "${GREY}--------------------------------------------${RESET}"
    echo -e "${WHITE} [1]${RESET} Conectar vía ${YELLOW}DATOS MÓVILES${RESET} (Red Móvil)"
    echo -e "${WHITE} [2]${RESET} Conectar vía ${GREEN}WIFI / ETECSA${RESET} (Red Inalámbrica)"
    echo -e "${WHITE} [3]${RESET} Instalar/Actualizar Dependencias"
    echo -e "${WHITE} [0]${RESET} ${RED}SALIR${RESET}"
    echo -e ""
    read -p " Selecciona una opción: " opt

    case $opt in
        1) conectar_auto "${DATA_SERVERS[@]}" ;;
        2) conectar_auto "${WIFI_SERVERS[@]}" ;;
        3) 
            echo -e "${CYAN}Instalando wget y herramientas...${RESET}"
            pkg install wget termux-tools -y
            read -p "Presiona Enter..." 
            ;;
        0) 
            limpiar_procesos
            clear
            exit 0 
            ;;
        *) echo "Opción no válida" ;;
    esac
done
