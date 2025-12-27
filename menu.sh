#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CLIENTE OFICIAL - SS_MADARAS VIP (ETECSA MOD)
# ==========================================

# CONFIGURACIÓN DEL TRUCO (DOMINIO FANTASMA)
DOMAIN="cdn.etecsa.news"
MY_VPS="217.156.64.35:53" # Tu IP de AlexHost
ACTIVE_DNS="No conectado"
LOG_FILE="$HOME/.slipstream/slip.log"
CLIENT_BIN="./slipstream-client"

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

connect_vip() {
    clean_slipstream
    > "$LOG_FILE"
    
    clear
    echo -e "${P}🦊 SS_MADARAS VIP - CONECTANDO...${NC}"
    echo -e "${C}Modo: ${W}Camuflaje ETECSA News${NC}"
    echo -e "${Y}[*] Apuntando a: ${W}$MY_VPS${NC}"
    echo "------------------------------------"

    # Comando optimizado con GSO y puerto 8080
    $CLIENT_BIN \
        --congestion-control=cubic \
        --tcp-listen-port=8080 \
        --resolver="$MY_VPS" \
        --domain="$DOMAIN" \
        --keep-alive-interval=120000 \
        --gso=true \
        > >(tee -a "$LOG_FILE") 2>&1 &

    # Validación de conexión
    for i in {1..12}; do
        if grep -q "Connection confirmed" "$LOG_FILE"; then
            ACTIVE_DNS="$MY_VPS"
            clear
            echo -e "${G}███████████████████████████████████${NC}"
            echo -e "${G}     CONEXIÓN REAL CONFIRMADA      ${NC}"
            echo -e "${G}███████████████████████████████████${NC}"
            echo -e "${W}Disfraz: ${C}$DOMAIN${NC}"
            echo -e "${W}Puerto Local: ${P}8080${NC}"
            echo "------------------------------------"
            echo -e "${Y}Presione CTRL+C para desconectar.${NC}"
            wait
            return
        fi
        echo -ne "${Y}Buscando túnel... $i/12\r${NC}"
        sleep 1
    done

    clean_slipstream
    echo -e "\n${R}[!] El servidor no respondió. Revisa el VPS.${NC}"
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
    echo -e "${W}1) CONECTAR (Modo Fantasma)${NC}"
    echo -e "${W}2) Actualizar Sistema${NC}"
    echo -e "${R}0) Salir${NC}"
    echo ""
    read -p "Seleccione: " opt

    case $opt in
        1) connect_vip ;;
        2) ./setup.sh ;;
        0) clean_slipstream; exit ;;
    esac
done
