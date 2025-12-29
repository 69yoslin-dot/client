#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURACIÓN VIP ---
DOMAIN="freezing-dns.duckdns.org"
# -------------------------

LOG_FILE="$HOME/.slip.log"

clean() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

setup() {
    if [ ! -f "./slipstream-client" ]; then
        clear
        echo "[*] Instalando motor VIP..."
        pkg update -y >/dev/null 2>&1
        pkg install wget dos2unix -y >/dev/null 2>&1
        wget -q https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
        chmod +x slipstream-client
        sleep 2
    fi
}

connect() {
    local SERVERS=("$@")
    clean
    for SERVER in "${SERVERS[@]}"; do
        echo "[*] Intentando conectar con: $SERVER"
        
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=120000 \
            --congestion-control=cubic \
            --gso=false > "$LOG_FILE" 2>&1 &
        
        for i in {1..10}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                clear
                echo "========================================="
                echo "      [✓] CONEXIÓN VIP ACTIVA"
                echo "========================================="
                echo " DNS: $SERVER"
                echo "-----------------------------------------"
                echo " 1. HTTP Custom -> Proxified Apps -> Termux"
                echo " 2. Activa BYPASS MODE"
                echo " 3. SSH: 127.0.0.1:5201"
                echo "-----------------------------------------"
                wait
                return
            fi
            sleep 1
        done
        clean
    done
    echo "[X] No se pudo conectar."
    read -p "ENTER para volver"
}

setup
while true; do
    clear
    echo "  ██╗   ██╗██╗██████╗ "
    echo "  ██║   ██║██║██╔══██╗"
    echo "  ██║   ██║██║██████╔╝"
    echo "  ╚██╗ ██╔╝██║██╔═══╝ "
    echo "   ╚████╔╝ ██║██║     "
    echo "    ╚═══╝  ╚═╝╚═╝     "
    echo "    --- FREEZING-DNS VIP ---"
    echo "-----------------------------------------"
    # Detección de red protegida para evitar el error de Permisos
    NET_INFO=$(ip route show 2>/dev/null | grep default | awk '{print $5}')
    echo " Red: ${NET_INFO:-Desconocida (Sin Permisos)}"
    echo "-----------------------------------------"
    echo " 1) DATOS MÓVILES"
    echo " 2) WIFI"
    echo " 0) SALIR"
    echo "-----------------------------------------"
    read -p " Opción: " opt
    case $opt in
        1) connect "200.55.128.130:443" "200.55.128.140:443" "200.55.128.230:443" "200.55.128.250:443" ;;
        2) connect "181.225.231.120:443" "181.225.231.110:443" "181.225.233.40:443" "181.225.233.30:443" ;;
        0) clean; exit ;;
    esac
done
