#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACION DEL DUEÑO
DOMAIN="freezing.2bd.net"
OWNER="SS.MADARAS"
TELEGRAM="https://t.me/ss_madaras"

# DIRECTORIOS
LOG_DIR="$HOME/.ss_madaras"
LOG_FILE="$LOG_DIR/connection.log"
mkdir -p "$LOG_DIR"

# COLORES Y ESTILOS
R='\033[1;31m' # Rojo
G='\033[1;32m' # Verde
Y='\033[1;33m' # Amarillo
B='\033[1;34m' # Azul
M='\033[1;35m' # Magenta
C='\033[1;36m' # Cyan
W='\033[0m'    # Blanco
BOLD='\033[1m'

# SERVIDORES ETECSA (DNS RELAY)
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

ACTIVE_DNS="${R}Desconectado${W}"

# FUNCION LIMPIEZA
cleanup() {
    pkill -f slipstream-client 2>/dev/null
    rm -f "$LOG_FILE"
}

# INTERRUPCION CTRL+C
trap_ctrl_c() {
    echo -e "\n${R}[!] Deteniendo servicios...${W}"
    cleanup
    ACTIVE_DNS="${R}Desconectado${W}"
    sleep 1
    return
}

# CABECERA GRAFICA
header() {
    clear
    echo -e "${B}███${C}╗   ${B}███${C}╗ ${B}█████${C}╗ ${B}██████${C}╗  ${B}█████${C}╗ ${B}██████${C}╗  ${B}█████${C}╗ ${B}███████${C}╗"
    echo -e "${B}████${C}╗ ${B}████${C}║${B}██${C}╔══${B}██${C}╗${B}██${C}╔══${B}██${C}╗${B}██${C}╔══${B}██${C}╗${B}██${C}╔══${B}██${C}╗${B}██${C}╔══${B}██${C}╗${B}██${C}╔════╝"
    echo -e "${B}██${C}╔${B}████${C}╔${B}██${C}║${B}███████${C}║${B}██${C}║  ${B}██${C}║${B}███████${C}║${B}██████${C}╔╝${B}███████${C}║${B}███████${C}╗"
    echo -e "${B}██${C}║╚${B}██${C}╔╝${B}██${C}║${B}██${C}╔══${B}██${C}║${B}██${C}║  ${B}██${C}║${B}██${C}╔══${B}██${C}║${B}██${C}╔══${B}██${C}╗${B}██${C}╔══${B}██${C}║╚════${B}██${C}║"
    echo -e "${B}██${C}║ ╚═╝ ${B}██${C}║${B}██${C}║  ${B}██${C}║${B}██████${C}╔╝${B}██${C}║  ${B}██${C}║${B}██${C}║  ${B}██${C}║${B}██${C}║  ${B}██${C}║${B}███████${C}║"
    echo -e "╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝${W}"
    echo -e "${C}          Freezing DNS Tunnel | By ${OWNER}${W}"
    echo -e "${W}=====================================================${W}"
    echo -e "   ${Y}Dominio:${W} $DOMAIN"
    echo -e "   ${Y}Estado :${W} $ACTIVE_DNS"
    echo -e "${W}=====================================================${W}"
}

# DETECTOR DE RED
detect_net() {
    local iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    if [[ "$iface" == wlan* ]]; then
        echo "WIFI"
    else
        echo "DATA"
    fi
}

connect_logic() {
    local SERVERS=("$@")
    
    for SERVER in "${SERVERS[@]}"; do
        cleanup
        header
        echo -e "${Y}[*] Intentando conectar vía: ${W}$SERVER"
        
        trap trap_ctrl_c INT

        # EJECUCION DEL CLIENTE
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &
            
        PID=$!
        
        # BARRA DE CARGA FALSA MIENTRAS CONECTA
        echo -ne "${C}[Espere] Conectando${W} "
        for i in {1..5}; do echo -ne "."; sleep 0.5; done
        echo ""

        if grep -q "Connection confirmed" "$LOG_FILE"; then
             ACTIVE_DNS="${G}CONECTADO ($SERVER)${W}"
             header
             echo -e "${G} [✓] CONEXIÓN ESTABLECIDA CON ÉXITO ${W}"
             echo -e "${W} ---------------------------------- ${W}"
             echo -e "  El túnel está activo en segundo plano."
             echo -e "  Mantén esta ventana abierta."
             echo -e "  Pulsa ${R}Ctrl + C${W} para desconectar."
             echo -e "${W} ---------------------------------- ${W}"
             
             # MANTENER VIVO EL LOOP HASTA CTRL+C
             while true; do
                if ! kill -0 $PID 2>/dev/null; then
                    echo -e "\n${R}[!] Conexión perdida.${W}"
                    break
                fi
                sleep 2
             done
             return
        fi
        
        # SI FALLA
        kill $PID 2>/dev/null
    done
    
    echo -e "\n${R}[X] No se pudo conectar con ningún servidor DNS.${W}"
    read -p "Presiona ENTER para volver..."
}

# MENU PRINCIPAL
while true; do
    NET_TYPE=$(detect_net)
    if [ "$NET_TYPE" == "DATA" ]; then
        ICON_DATA="${G}●${W}"
        ICON_WIFI="${R}○${W}"
    else
        ICON_DATA="${R}○${W}"
        ICON_WIFI="${G}●${W}"
    fi

    header
    echo -e "${W}  1) ${ICON_DATA} Conectar ETECSA (Datos Móviles)"
    echo -e "${W}  2) ${ICON_WIFI} Conectar ETECSA (WiFi / Nauta)"
    echo -e "${W}  3) ${C}Contactar Soporte (Telegram)${W}"
    echo -e "${W}  0) ${R}Salir${W}"
    echo ""
    read -p "  Selecciona una opción: " opt

    case $opt in
        1) connect_logic "${DATA_SERVERS[@]}" ;;
        2) connect_logic "${WIFI_SERVERS[@]}" ;;
        3) am start -a android.intent.action.VIEW -d "$TELEGRAM" >/dev/null 2>&1 ;;
        0) cleanup; clear; exit ;;
        *) echo -e "${R}Opción inválida${W}"; sleep 1 ;;
    esac
done
