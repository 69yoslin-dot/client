#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CLIENTE OFICIAL - SS_MADARAS VIP (v2.2)
#  Optimizado para: freezing.2bd.net
# ==========================================

# --- CONFIGURACIÓN DEL USUARIO ---
# Actualizado al nuevo dominio gratuito configurado en FreeDomain.One
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
"217.156.64.35:53" # Tu IP directa como respaldo
)

WIFI_SERVERS=(
"181.225.231.120:53"
"181.225.231.110:53"
"181.225.233.40:53"
"181.225.233.30:53"
"217.156.64.35:53" # Tu IP directa como respaldo
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
    echo -e "${W}     Premium VIP v2.2"
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
        
        banner
        echo -e "${Y}[*] Buscando túnel DNS funcional...${W}"
        echo -e "Probando DNS : ${C}$SERVER${W}"
        echo -e "Dominio Host : ${C}$DOMAIN${W}"
        echo ""
        
        trap trap_ctrl_c INT

        # Ejecución del binario
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &
            
        PID=$!
        
        # Animación de conexión
        echo -ne "${G}Sincronizando: [${W}"
        for k in {1..10}; do echo -ne "▓"; sleep 0.1; done
        echo -e "${G}]${W}"

        # Validación de respuesta del servidor (10 segundos para DNS lento)
        for i in {1..10}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                banner
                echo -e "${G}██████████████████████████████${W}"
                echo -e "${G}   CONEXIÓN REAL CONFIRMADA   ${W}"
                echo -e "${G}██████████████████████████████${W}"
                echo -e "Servidor   : ${Y}$SERVER${W}"
                echo -e "Puerto Loc : ${P}127.0.0.1:5201${W}"
                echo -e "Estado     : ${G}ONLINE ⚡${W}"
                echo -e "${W}------------------------------"
                echo -e "${C}Recuerda configurar tu App VPN${W}"
                echo -e "${C}Host: 127.0.0.1 | Puerto: 5201${W}"
                echo -e "------------------------------"
                echo -e "${R}Presiona Ctrl + C para salir.${W}"
                
                # Mantener el proceso vivo
                while kill -0 $PID 2>/dev/null; do
                    sleep 2
                done
                
                trap - INT
                return
            fi
            
            if grep -q "Connection closed" "$LOG_FILE"; then
                echo -e "${R}[X] Rechazado por el servidor.${W}"
                break
            fi
            sleep 1
        done
        
        trap - INT
        clean_slipstream
        echo -e "${R}[!] Fallo en $SERVER. Saltando...${W}"
        sleep 1
    done
    
    echo -e "\n${R}[X] Agotados todos los servidores DNS.${W}"
    echo -e "${Y}Asegúrate de que el servidor en la VPS esté activo.${W}"
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
