#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CLIENTE OFICIAL - SS_MADARAS VIP (v2.4)
#  Corregido: Error de log y salida limpia
# ==========================================

# --- CONFIGURACIÓN DEL USUARIO ---
DOMAIN="freezing.2bd.net" 
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
    echo -e "${W}     Premium VIP v2.4"
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
    
    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        
        # [CORRECCIÓN 1] Creamos el archivo antes para evitar errores
        touch "$LOG_FILE"
        
        banner
        echo -e "${Y}[*] Buscando túnel DNS funcional...${W}"
        echo -e "Probando DNS : ${C}$SERVER${W}"
        echo -e "Dominio Host : ${C}$DOMAIN${W}"
        echo ""
        
        trap trap_ctrl_c INT

        # [CORRECCIÓN 2] Redirección limpia (ya no ensucia la pantalla)
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > "$LOG_FILE" 2>&1 &
            
        PID=$!
        
        # Animación de intento
        echo -ne "${B}Sincronizando... ${W}"
        
        SERVER_OK=false
        # Esperamos respuesta (4 segundos)
        for i in {1..4}; do
            # Grep lee el archivo silenciosamente
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                SERVER_OK=true
                break
            fi
            echo -ne "▓"
            sleep 1
        done

        if $SERVER_OK; then
            banner
            echo -e "${G}██████████████████████████████${W}"
            echo -e "${G}   CONEXIÓN REAL CONFIRMADA   ${W}"
            echo -e "${G}██████████████████████████████${W}"
            echo -e "Servidor   : ${Y}$SERVER${W}"
            echo -e "Puerto Loc : ${Y}127.0.0.1:5201${W}"
            echo -e "Estado     : ${G}ONLINE ⚡${W}"
            echo -e "${W}------------------------------"
            echo -e "${C}Recuerda configurar tu App VPN${W}"
            echo -e "${R}Presiona Ctrl + C para detener.${W}"
            
            # Bucle de mantenimiento
            while true; do
                if ! kill -0 $PID 2>/dev/null; then
                    echo -e "\n${R}[!] El proceso murió inesperadamente.${W}"
                    break
                fi
                
                if grep -q "Connection closed" "$LOG_FILE"; then
                    echo -e "\n${R}[!] El servidor cerró la conexión.${W}"
                    break
                fi
                sleep 2
            done
            
            clean_slipstream
        else
            echo -e "\n${R}[X] Sin respuesta en este DNS.${W}"
            clean_slipstream
        fi
        
    done
    
    echo -e "\n${R}[X] Agotados todos los servidores DNS.${W}"
    echo -e "${Y}Verifica tu conexión o el estado de la VPS.${W}"
    read -p "Presiona ENTER para volver..."
}

# --- BUCLE PRINCIPAL ---
while true; do
    banner
    
    echo -e "${Y}MENÚ DE CONEXIÓN - SS.MADARAS:${W}"
    echo -e ""
    echo -e "${G}[1]${W} ● DATOS MÓVILES (Etecsa)"
    echo -e "${G}[2]${W} ● WIFI NAUTA / HOGAR"
    echo -e ""
    echo -e "${W}------------------------------"
    echo -e "${C}[3]${W} Soporte Técnico (Admin)"
    echo -e "${C}[4]${W} Grupo Oficial"
    echo -e "${R}[0]${W} Apagar Sistema"
    echo -e ""
    echo -ne "${B}Selección >> ${W}"
    read opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) am start -a android.intent.action.VIEW -d "$ADMIN_LINK" >/dev/null 2>&1 ;;
        4) am start -a android.intent.action.VIEW -d "$CANAL_LINK" >/dev/null 2>&1 ;;
        0) 
            clean_slipstream
            clear
            echo -e "${G}Cerrando SS.MADARAS VIP. ¡Hasta luego!${W}"
            exit 
            ;;
        *) 
            echo -e "\n${R}Opción inválida.${W}"
            sleep 1
            ;;
    esac
done
