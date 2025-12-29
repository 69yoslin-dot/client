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
B='\033[1;34m' # Azul

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
    echo -e "${W}     Premium VIP v2.1"
    echo -e "${C}   By SS.MADARAS | CUBA"
    echo -e "${W}=============================="
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
    local TYPE_NAME="$1" # Truco: Pasaremos el nombre como primer argumento si queremos imprimirlo, o lo ignoramos
    
    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        
        banner
        echo -e "${Y}[*] Buscando servidor funcional...${W}"
        echo -e "Probando DNS: ${C}$SERVER${W}"
        echo -e "Dominio Host: ${C}$DOMAIN${W}"
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
        
        # Barra de carga rápida
        echo -ne "${G}Conectando: [${W}"
        for k in {1..10}; do echo -ne "#"; sleep 0.1; done
        echo -e "${G}]${W}"

        # Verificar conexión (7 segundos máx)
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                banner
                echo -e "${G}[✓] CONEXIÓN ESTABLECIDA EXITOSAMENTE${W}"
                echo -e "${W}------------------------------"
                echo -e "DNS Activo : ${Y}$SERVER${W}"
                echo -e "Estado     : ${G}ONLINE ⚡${W}"
                echo -e "Protocolo  : ${C}QUIC/UDP${W}"
                echo -e "${W}------------------------------"
                echo -e "${C}>> Minimiza Termux y disfruta <<${W}"
                echo -e "${R}Presiona Ctrl + C para desconectar.${W}"
                
                # Bucle de espera
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
    
    echo -e "\n${R}[X] No se pudo conectar con ningún servidor.${W}"
    echo -e "${Y}Verifica si tienes datos activos o si elegiste la opción correcta.${W}"
    read -p "Presiona ENTER para volver al menú..."
}

# --- BUCLE PRINCIPAL ---
while true; do
    banner
    
    echo -e "${Y}SELECCIONA TU TIPO DE CONEXIÓN:${W}"
    echo -e ""
    echo -e "${G}[1]${W} ● Conexión por DATOS MÓVILES"
    echo -e "${G}[2]${W} ● Conexión por WIFI / NAUTA"
    echo -e ""
    echo -e "${W}------------------------------"
    echo -e "${C}[3]${W} Contactar Admin (Telegram)"
    echo -e "${C}[4]${W} Canal Oficial"
    echo -e "${R}[0]${W} Salir del Script"
    echo -e ""
    echo -ne "${B}Opción >> ${W}"
    read opt

    case $opt in
        1) 
            connect_auto "${DATA_SERVERS[@]}"
            ;;
        2) 
            connect_auto "${WIFI_SERVERS[@]}"
            ;;
        3) 
            am start -a android.intent.action.VIEW -d "$ADMIN_LINK" >/dev/null 2>&1
            ;;
        4) 
            am start -a android.intent.action.VIEW -d "$CANAL_LINK" >/dev/null 2>&1
            ;;
        0) 
            clean_slipstream
            clear
            echo -e "${G}Gracias por usar SS.MADARAS Services.${W}"
            exit 
            ;;
        *) 
            echo -e "\n${R}Opción no válida.${W}"
            sleep 1
            ;;
    esac
done
