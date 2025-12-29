#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURACIÓN DEL USUARIO ---
DOMAIN="freezing-dns.duckdns.org"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
ADMIN_LINK="https://t.me/ss_madaras"
CANAL_LINK="https://t.me/internet_gratis_canal"

# --- COLORES ---
R='\033[1;31m' # Rojo
G='\033[1;32m' # Verde
Y='\033[1;33m' # Amarillo
C='\033[1;36m' # Cyan
W='\033[0m'    # Blanco
M='\033[1;35m' # Magenta

mkdir -p "$LOG_DIR"

# --- SERVIDORES DNS ETECSA ---
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

# --- FUNCIONES ---

banner() {
    clear
    echo -e "${M}"
    echo " ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  "
    echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌ "
    echo "▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀  "
    echo "▐░▌          ▐░▌           "
    echo "▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄  "
    echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌ "
    echo " ▀▀▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀█░▌ "
    echo "          ▐░▌          ▐░▌ "
    echo " ▄▄▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌ "
    echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌ "
    echo " ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  "
    echo -e "${W}     Premium VIP v2.0"
    echo -e "${C}   By SS.MADARAS | CUBA"
    echo -e "${W}=============================="
}

detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATA"
}

clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    rm -f "$LOG_FILE"
}

trap_ctrl_c() {
    echo -e "\n${R}[!] Deteniendo servicios...${W}"
    clean_slipstream
    sleep 1
    return
}

connect_auto() {
    local SERVERS=("$@")
    
    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        
        banner
        echo -e "${Y}[*] Intentando conectar...${W}"
        echo -e "DNS: ${C}$SERVER${W}"
        echo -e "Host: ${C}$DOMAIN${W}"
        echo ""
        
        trap trap_ctrl_c INT

        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &
            
        PID=$!
        
        # Barra de carga falsa para efecto visual
        echo -ne "${G}Conectando: [${W}"
        for k in {1..10}; do echo -ne "#"; sleep 0.2; done
        echo -e "${G}]${W}"

        # Verificar conexión (7 segundos máx)
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                banner
                echo -e "${G}[✓] CONEXIÓN ESTABLECIDA${W}"
                echo -e "${W}------------------------------"
                echo -e "DNS Activo : ${Y}$SERVER${W}"
                echo -e "Estado     : ${G}ONLINE${W}"
                echo -e "Transporte : ${C}QUIC/UDP${W}"
                echo -e "${W}------------------------------"
                echo -e "${C}Minimiza Termux y disfruta.${W}"
                echo -e "${R}Presiona Ctrl + C para desconectar.${W}"
                
                # Mantener script vivo esperando Ctrl+C
                while kill -0 $PID 2>/dev/null; do
                    sleep 2
                done
                
                trap - INT
                return
            fi
            
            if grep -q "Connection closed" "$LOG_FILE"; then
                break
            fi
            sleep 1
        done
        
        trap - INT
        clean_slipstream
    done
    
    echo -e "\n${R}[X] Fallo al conectar con los servidores disponibles.${W}"
    read -p "Presiona ENTER para volver..."
}

# --- BUCLE PRINCIPAL ---
while true; do
    banner
    
    NET=$(detect_network)
    STATUS_TXT="${R}DESCONECTADO${W}"
    [[ "$NET" == "DATA" ]] && NET_TYPE="${Y}DATOS MÓVILES${W}"
    [[ "$NET" == "WIFI" ]] && NET_TYPE="${C}WI-FI${W}"
    
    echo -e "RED DETECTADA: $NET_TYPE"
    echo -e ""
    echo -e "${G}[1]${W} Conectar (Automático)"
    echo -e "${G}[2]${W} Contactar Soporte (Telegram)"
    echo -e "${G}[3]${W} Unirse al Canal"
    echo -e "${R}[0]${W} Salir"
    echo -e ""
    echo -ne "${Y}Selecciona una opción: ${W}"
    read opt

    case $opt in
        1) 
            if [[ "$NET" == "WIFI" ]]; then
                connect_auto "${WIFI_SERVERS[@]}"
            else
                connect_auto "${DATA_SERVERS[@]}"
            fi
            ;;
        2) 
            am start -a android.intent.action.VIEW -d "$ADMIN_LINK" >/dev/null 2>&1
            ;;
        3) 
            am start -a android.intent.action.VIEW -d "$CANAL_LINK" >/dev/null 2>&1
            ;;
        0) 
            clean_slipstream
            clear
            echo -e "${G}Gracias por usar SS.MADARAS Services.${W}"
            exit 
            ;;
        *) 
            ;;
    esac
done
