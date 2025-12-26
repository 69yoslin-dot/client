#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURACIÓN SS_MADARAS ---
DOMAIN="freezing-dns.duckdns.org"
LOG_FILE="$HOME/.madaras_log"

# --- IPS ETECSA / CUBACEL ---
declare -a DATA_SERVERS=(
"200.55.128.130:53"
"200.55.128.140:53"
"200.55.128.230:53"
"200.55.128.250:53"
)

declare -a WIFI_SERVERS=(
"181.225.231.120:53"
"181.225.231.110:53"
"181.225.233.40:53"
"181.225.233.30:53"
)

# --- ESTILOS ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'

limpiar() {
    clear
    pkill -f slipstream-client 2>/dev/null
    rm -f "$LOG_FILE"
}

abrir_telegram() {
    am start -a android.intent.action.VIEW -d "https://t.me/ss_madaras" > /dev/null 2>&1
}

banner() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║        🦊 SS_MADARAS VIP 🦊          ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════╝${NC}"
    echo -e "${WHITE}  Telegram: ${CYAN}@ss_madaras${NC}"
    echo -e "${WHITE}  Canal:    ${CYAN}@internet_gratis_canal${NC}"
    echo -e "${BLUE}────────────────────────────────────────${NC}"
}

conectar() {
    local TIPO_RED=$1
    local SERVIDORES=("${!2}")
    
    for SERVER in "${SERVIDORES[@]}"; do
        limpiar
        banner
        echo -e "${YELLOW}⚡ Conectando vía: ${WHITE}$TIPO_RED${NC}"
        echo -e "${CYAN}🌍 Server DNS: ${WHITE}$SERVER${NC}"
        echo ""
        
        # INICIO DEL CLIENTE
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=60 \
            > "$LOG_FILE" 2>&1 &
            
        PID=$!
        
        # Animación de espera
        echo -ne "${YELLOW}Estableciendo túnel... [░░░░░░] 0%\r"
        sleep 1
        echo -ne "${YELLOW}Estableciendo túnel... [████░░] 60%\r"
        sleep 2
        
        # Verificamos si el proceso sigue vivo (señal de que no crasheó al inicio)
        if ps -p $PID > /dev/null; then
             echo -ne "${GREEN}Estableciendo túnel... [██████] 100%${NC}\n"
             echo ""
             echo -e "${GREEN}★ ¡CONECTADO CON ÉXITO! ★${NC}"
             echo -e "${BLUE}────────────────────────────────────────${NC}"
             echo -e "${WHITE} Abre HTTP Custom y pon:${NC}"
             echo -e "${PURPLE} 127.0.0.1:5201${NC}"
             echo ""
             echo -e "${YELLOW} [!] No cierres Termux. Minimízalo.${NC}"
             
             # Bucle para mantener vivo y mostrar logs graves
             tail -f "$LOG_FILE" | grep --line-buffered -E "Error|Closed"
             return
        else
            echo -ne "${RED}Fallo en conexión. Probando siguiente...${NC}\n"
        fi
    done
    
    echo -e "\n${RED}[✖] No se pudo conectar. Revisa tu saldo/cobertura.${NC}"
    read -p "ENTER para volver"
}

# --- MENU PRINCIPAL ---
while true; do
    banner
    echo -e "${WHITE}[1] ${CYAN}Conectar Datos (Red Móvil)${NC}"
    echo -e "${WHITE}[2] ${CYAN}Conectar WiFi (Nauta)${NC}"
    echo -e "${WHITE}[3] ${CYAN}Contactar Admin (Telegram)${NC}"
    echo -e "${WHITE}[0] ${RED}Salir${NC}"
    echo ""
    echo -ne "${PURPLE}Opción > ${NC}"
    read opcion

    case $opcion in
        1) conectar "DATOS MOVILES" DATA_SERVERS[@] ;;
        2) conectar "WIFI NAUTA" WIFI_SERVERS[@] ;;
        3) abrir_telegram ;;
        0) limpiar; exit 0 ;;
        *) ;;
    esac
done
