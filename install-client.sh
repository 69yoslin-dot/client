#!/data/data/com.termux/files/usr/bin/bash
# Nombre del archivo: setup.sh

# --- CONFIGURACIÓN MAESTRA ---
DOMAIN="freezing-dns.duckdns.org"
LOCAL_PORT="5201"
# -----------------------------

LOG_FILE="$HOME/.slipstream_log"
trap "pkill -f slipstream-client; exit" SIGINT SIGTERM

# Servidores DNS (ETECSA / Cuba)
DATA_SERVERS=("200.55.128.130:53" "200.55.128.140:53" "200.55.128.3:53" "200.55.128.4:53")
WIFI_SERVERS=("181.225.231.120:53" "181.225.231.110:53" "181.225.233.40:53")

start_tunnel() {
    local DNS_IP="$1"
    pkill -f slipstream-client
    
    echo -e "\e[1;33m[*] Conectando a través de: $DNS_IP ...\e[0m"
    
    # Ejecución oculta
    ./slipstream-client \
        --tcp-listen-port=$LOCAL_PORT \
        --resolver="$DNS_IP" \
        --domain="$DOMAIN" \
        --keep-alive-interval=20 \
        > "$LOG_FILE" 2>&1 &
        
    PID=$!
    
    # Barra de carga falsa para dar tiempo a la conexión
    echo -ne "\e[1;36m[Espere] \e[0m"
    for i in {1..5}; do echo -ne "▓"; sleep 1; done
    echo ""

    # Verificación simple (Revisa si el proceso sigue vivo)
    if ps -p $PID > /dev/null; then
        clear
        echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "\e[1;37m        CONEXIÓN ESTABLECIDA            \e[0m"
        echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e " \e[1;34m»\e[0m Estado: \e[1;32mONLINE\e[0m"
        echo -e " \e[1;34m»\e[0m DNS:    \e[1;37m$DNS_IP\e[0m"
        echo -e " \e[1;34m»\e[0m Server: \e[1;37m$DOMAIN\e[0m"
        echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "\e[1;33m[!] Configura tu HTTP Custom / Injector:\e[0m"
        echo -e "    IP: 127.0.0.1"
        echo -e "    Puerto: $LOCAL_PORT"
        echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "\e[1;30mPresiona ENTER para desconectar y salir...\e[0m"
        read temp
        pkill -f slipstream-client
    else
        echo -e "\e[1;31m[!] Falló la conexión con este DNS.\e[0m"
        sleep 2
    fi
}

menu() {
    while true; do
        clear
        echo -e "\e[1;36m   SS.MADARAS | $DOMAIN \e[0m"
        echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "  \e[1;37m[1]\e[0m Conectar Datos Móviles (Auto)"
        echo -e "  \e[1;37m[2]\e[0m Conectar WiFi / Nauta (Auto)"
        echo -e "  \e[1;37m[0]\e[0m Salir"
        echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        read -p "Elige una opción: " opt

        case $opt in
            1) 
                for server in "${DATA_SERVERS[@]}"; do
                    start_tunnel "$server"
                    break # Quita este break si quieres que pruebe el siguiente si falla
                done
                ;;
            2)
                for server in "${WIFI_SERVERS[@]}"; do
                    start_tunnel "$server"
                    break
                done
                ;;
            0) exit 0 ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

menu
