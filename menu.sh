#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CLIENTE OFICIAL - SS_MADARAS VIP
# ==========================================

DOMAIN="freezing-dns.duckdns.org"
ACTIVE_DNS="No conectado"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
CLIENT_BIN="./slipstream-client"

mkdir -p "$LOG_DIR"

# Servidores oficiales de ETECSA
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

# Colores para la interfaz
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

trap_ctrl_c() {
    echo -e "\n${R}[!] Conexión interrumpida por el usuario${NC}"
    clean_slipstream
    ACTIVE_DNS="No conectado"
    sleep 2
}

connect_auto() {
    local SERVERS=("$@")

    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"

        clear
        echo -e "${P}🦊 SS_MADARAS VIP${NC}"
        echo -e "${Y}[*] Probando servidor: ${W}$SERVER${NC}"
        echo -e "${C}Dominio: ${W}$DOMAIN${NC}"
        echo "------------------------------------"

        trap trap_ctrl_c INT

        # Ejecución del binario enviando salida al log
        $CLIENT_BIN \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &

        PID=$!

        # VALIDACIÓN ÉTICA: Esperamos hasta 10 segundos por la confirmación real
        for i in {1..10}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                echo -e "${G}███████████████████████████████████${NC}"
                echo -e "${G}     CONEXIÓN REAL CONFIRMADA      ${NC}"
                echo -e "${G}███████████████████████████████████${NC}"
                echo -e "${W}DNS Activo: ${C}$ACTIVE_DNS${NC}"
                echo -e "${W}Puerto Local: ${P}127.0.0.1:5201${NC}"
                echo "------------------------------------"
                echo -e "${Y}Escriba 'menu' para desconectar y volver.${NC}"
                echo ""

                # Bucle de espera de comando
                while true; do
                    echo -n "ss_madaras > "
                    read -r input
                    [[ -z "$input" ]] && continue
                    if [[ "${input,,}" == "menu" ]]; then
                        clean_slipstream
                        ACTIVE_DNS="No conectado"
                        return
                    fi
                done
                trap - INT
                return
            fi

            if grep -q "Connection closed" "$LOG_FILE"; then
                echo -e "${R}[X] Servidor rechazó la conexión.${NC}"
                break
            fi
            echo -ne "${Y}Esperando respuesta... $i/10\r${NC}"
            sleep 1
        done

        trap - INT
        clean_slipstream
        echo -e "\n${R}[!] Falló servidor $SERVER${NC}"
        sleep 1
    done

    echo -e "\n${R}[X] No se pudo establecer el túnel DNS.${NC}"
    read -p "Presione ENTER para volver"
}

while true; do
    clear
    NET=$(detect_network)
    echo -e "${P}      SS_MADARAS VIP CLIENT        ${NC}"
    echo -e "${C}      Canal: @ss_madaras           ${NC}"
    echo "------------------------------------"
    echo -e "${W}Red detectada: ${Y}$NET${NC}"
    echo -e "${W}Estado actual: ${G}$ACTIVE_DNS${NC}"
    echo "------------------------------------"
    echo -e "${W}1) Conectar en Datos Móviles${NC}"
    echo -e "${W}2) Conectar en WiFi Nauta${NC}"
    echo -e "${W}3) Actualizar Binarios${NC}"
    echo -e "${R}0) Salir${NC}"
    echo ""
    read -p "Seleccione: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) ./setup.sh ;;
        0) clear; exit ;;
    esac
done
