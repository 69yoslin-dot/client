#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# CONFIGURACION DEL DUEÑO
# ==========================================
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

# DETECTOR DE ERRORES EN LOG (NUEVO: MEJORA DE ESTABILIDAD)
dns_dead() {
    grep -qE "Connection closed|resolver timeout|no response|broken pipe" "$LOG_FILE"
}

# INTERRUPCION CTRL+C
trap_ctrl_c() {
    echo -e "\n${R}[!] Deteniendo servicios y volviendo al menú...${W}"
    cleanup
    ACTIVE_DNS="${R}Desconectado${W}"
    sleep 1
    # Esto rompe el bucle de conexión y vuelve al menú principal
    return 1 2>/dev/null
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

# LOGICA DE CONEXION MEJORADA (MOTOR NUEVO)
connect_logic() {
    local SERVERS=("$@")
    
    # Trampa para salir del bucle infinito con Ctrl+C
    trap 'trap_ctrl_c; return' INT
    
    # Bucle infinito para auto-reconexión
    while true; do
        for SERVER in "${SERVERS[@]}"; do
            cleanup
            header
            echo -e "${Y}[*] Conectando vía: ${W}$SERVER"
            echo -e "${C}[i] Sistema de Auto-Reconexión: ACTIVO${W}"
            
            # EJECUCION DEL CLIENTE
            ./slipstream-client \
                --tcp-listen-port=5201 \
                --resolver="$SERVER" \
                --domain="$DOMAIN" \
                --keep-alive-interval=600 \
                --congestion-control=cubic \
                > >(tee -a "$LOG_FILE") 2>&1 &
                
            PID=$!
            
            # BARRA DE CARGA
            echo -ne "${C}[Espere] Conectando${W} "
            for i in {1..4}; do echo -ne "."; sleep 0.5; done
            echo ""

            # VERIFICACION INICIAL
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                 ACTIVE_DNS="${G}CONECTADO ($SERVER)${W}"
                 header
                 echo -e "${G} [✓] CONEXIÓN ESTABLECIDA ${W}"
                 echo -e "${W} ---------------------------------- ${W}"
                 echo -e "  El túnel está monitoreando la red..."
                 echo -e "  Si falla, cambiará de servidor solo."
                 echo -e "  Pulsa ${R}Ctrl + C${W} para volver al menú."
                 echo -e "${W} ---------------------------------- ${W}"
                 
                 # MANTENER VIVO Y VIGILAR LOGS (HEALTH CHECK)
                 while true; do
                    # 1. Chequeo de proceso
                    if ! kill -0 $PID 2>/dev/null; then
                        echo -e "\n${R}[!] Proceso detenido.${W}"
                        break # Rompe y va al siguiente server
                    fi
                    
                    # 2. Chequeo de errores en log (ZOMBIE KILLER)
                    if dns_dead; then
                        echo -e "\n${R}[!] Fallo de DNS detectado (Timeout).${W}"
                        echo -e "${Y}[*] Buscando siguiente servidor...${W}"
                        kill $PID 2>/dev/null
                        break # Rompe y va al siguiente server
                    fi
                    
                    sleep 2
                 done
            else
                # Si falló al iniciar
                kill $PID 2>/dev/null
            fi
        done
        
        # Si terminamos la lista de servidores, esperamos y reiniciamos
        echo -e "\n${R}[!] Ciclo completado. Reintentando en 3s...${W}"
        sleep 3
    done
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

    # Resetear trampa por si acaso
    trap - INT

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
