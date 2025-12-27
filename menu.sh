#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CLIENTE OFICIAL - SS_MADARAS VIP (ETECSA MOD)
# ==========================================

DOMAIN="cdn.etecsa.news"
MY_VPS="217.156.64.35:53"
ACTIVE_DNS="No conectado"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
CLIENT_BIN="./slipstream-client"

mkdir -p "$LOG_DIR"

# IPs de ETECSA que usa tu amigo
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

# COLORES
G='\033[1;32m'
R='\033[1;31m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
P='\033[1;35m'
NC='\033[0m'

detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATA"
}

clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

connect_auto() {
    local SERVERS=("$@")
    # Agregamos tu VPS al inicio de la lista para prioridad
    local FINAL_SERVERS=("$MY_VPS" "${SERVERS[@]}")

    for SERVER in "${FINAL_SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"
        clear
        echo -e "${P}🦊 SS_MADARAS VIP${NC}"
        echo -e "${Y}[*] Probando resolver: ${W}$SERVER${NC}"
        echo -e "${C}Disfraz: ${W}$DOMAIN${NC}"
        echo "------------------------------------"

        $CLIENT_BIN \
            --congestion-control=cubic \
            --tcp-listen-port=8080 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=120000 \
            --gso=true \
            > >(tee -a "$LOG_FILE") 2>&1 &

        for i in {1..15}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                echo -e "${G}███████████████████████████████████${NC}"
                echo -e "${G}     CONEXIÓN REAL CONFIRMADA      ${NC}"
                echo -e "${G}███████████████████████████████████${NC}"
                echo -e "${W}Resolver: ${C}$ACTIVE_DNS${NC}"
                echo -e "${W}Puerto Local: ${P}8080${NC}"
                echo "------------------------------------"
                echo -e "${Y}Presione CTRL+C para desconectar.${NC}"
                wait
                return
            fi
            echo -ne "${Y}Buscando túnel... $i/15\r${NC}"
            sleep 1
        done
        clean_slipstream
    done
    echo -e "\n${R}[!] Ningún servidor respondió.${NC}"
    read -p "Presione ENTER"
}

while true; do
    clear
    NET=$(detect_network)
    echo -e "${P}      SS_MADARAS VIP CLIENT        ${NC}"
    echo -e "${C}      Canal: @ss_madaras           ${NC}"
    echo "------------------------------------"
    echo -e "${W}Red detectada: ${Y}$NET${NC}"
    echo -e "${W}Estado: ${G}$ACTIVE_DNS${NC}"
    echo "------------------------------------"
    echo -e "${W}1) Conectar en Datos Móviles${NC}"
    echo -e "${W}2) Conectar en WiFi Nauta${NC}"
    echo -e "${W}3) Actualizar Sistema${NC}"
    echo -e "${R}0) Salir${NC}"
    echo ""
    read -p "Seleccione: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) ./setup.sh ;;
        0) clean_slipstream; exit ;;
    esac
done
