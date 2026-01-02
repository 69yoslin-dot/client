#!/data/data/com.termux/files/usr/bin/bash

# --- BLOQUE DE AUTO-DESCARGA DEL BINARIO ---
# URL de tu repositorio donde debe estar el archivo 'slipstream-client'
BIN_URL="https://raw.githubusercontent.com/69yoslin-dot/client/main/slipstream-client"
BIN_FILE="slipstream-client"

# Si el binario no existe, lo descarga
if [ ! -f "$BIN_FILE" ]; then
    echo -e "\e[33m[*] Descargando motor Slipstream (primera vez)...\e[0m"
    wget -q -O "$BIN_FILE" "$BIN_URL"
    if [ $? -ne 0 ]; then
        echo -e "\e[31m[!] Error descargando el binario. Verifica tu internet o el enlace.\e[0m"
        exit 1
    fi
    chmod +x "$BIN_FILE"
    echo -e "\e[32m[+] Descarga completada.\e[0m"
    sleep 1
fi

# Asegurar permisos siempre
chmod +x "$BIN_FILE"
# -------------------------------------------

clear

####################################
# CONFIGURACIÓN
####################################
# TU DOMINIO NS
DOMAIN="dns.madaras.work.gd"
SERVER_STATUS="DESCONOCIDO"

LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
mkdir -p "$LOG_DIR"

# SERVIDORES ETECSA
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

####################################
# COLORES Y ESTÉTICA
####################################
PURPLE="\e[38;5;93m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
GRAY="\e[90m"
BOLD="\e[1m"
RESET="\e[0m"

separator() {
    echo -e "${GRAY}────────────────────────────────────────${RESET}"
}

banner() {
    echo -e "${PURPLE}${BOLD}"
    echo "MADARAS DNS TUNNEL"
    echo "Running Slipstream QUIC"
    echo -e "${RESET}"
    printf "%35s${GREEN}Version: 1.0.8-MOD${RESET}\n"
}

checking_screen() {
    clear
    echo -e "${PURPLE}${BOLD}════════════════════════════════════════${RESET}"
    echo -e "${BOLD}     VERIFICANDO ESTADO DEL SERVIDOR     ${RESET}"
    echo -e "${PURPLE}${BOLD}════════════════════════════════════════${RESET}"
    echo
    echo -e "${GRAY}Espere unos segundos...${RESET}"
}

clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

####################################
# CHEQUEO TÉCNICO
####################################
check_server_on_start() {
    clean_slipstream
    > "$LOG_FILE"

    ./slipstream-client \
        --tcp-listen-port=5201 \
        --resolver=1.1.1.1:53 \
        --domain="$DOMAIN" \
        --keep-alive-interval=600 \
        --congestion-control=cubic \
        > "$LOG_FILE" 2>&1 &

    PID=$!
    SERVER_STATUS="INACTIVO"

    for i in {1..8}; do
        if grep -q "Connection confirmed" "$LOG_FILE"; then
            SERVER_STATUS="ACTIVO"
            break
        fi
        if grep -q "Connection closed" "$LOG_FILE"; then
            SERVER_STATUS="INACTIVO"
            break
        fi
        if kill -0 $PID 2>/dev/null && [ $i -ge 6 ]; then
            SERVER_STATUS="ACTIVO"
            break
        fi
        sleep 1
    done

    kill $PID 2>/dev/null
    clean_slipstream
}

show_server_status() {
    if [ "$SERVER_STATUS" = "ACTIVO" ]; then
        echo -e "${GREEN}${BOLD}✅ Estado del servidor: ACTIVO${RESET}"
    else
        echo -e "${RED}${BOLD}❌ Estado del servidor: INACTIVO${RESET}"
    fi
}

####################################
# CONEXIÓN AUTO
####################################
connect_auto() {
    local SERVERS=("$@")

    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"

        clear
        echo -e "${CYAN}[*] Probando servidor:${RESET} $SERVER"
        separator

        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &

        PID=$!

        for i in {1..5}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                clear
                echo -e "${GREEN}${BOLD}Servidor online ✅${RESET}"
                echo -e "${GREEN}DNS activo:${RESET} $SERVER"
                separator
                echo -e "${YELLOW}Local Port:${RESET} 127.0.0.1:5201"
                echo -e "${GRAY}Ctrl + C para desconectar${RESET}"
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

####################################
# INICIO
####################################
checking_screen
check_server_on_start

while true; do
    clear
    banner
    show_server_status
    separator
    echo " 1) Conectar en Datos Móviles"
    echo " 2) Conectar en WiFi"
    echo " 0) Salir"
    separator
    read -p "Selecciona una opción: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        0) clear; exit ;;
    esac
done
