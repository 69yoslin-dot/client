#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURACIÓN PERSONALIZADA ---
DOMAIN="freezing-dns.duckdns.org"
# ----------------------------------

LOG_FILE="$HOME/.slipstream.log"

# Función para limpiar procesos previos
clean() {
    pkill -f slipstream-client 2>/dev/null
}

# Instalación automática inicial
setup() {
    if [ ! -f "./slipstream-client" ]; then
        echo "[*] Configurando entorno VIP por primera vez..."
        pkg update -y && pkg upgrade -y
        pkg install wget dos2unix -y
        wget -q https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
        chmod +x slipstream-client
        echo "[✓] Instalación completada."
        sleep 2
    fi
}

# Lógica de conexión automática
connect() {
    local SERVERS=("$@")
    clean
    for SERVER in "${SERVERS[@]}"; do
        echo "[*] Probando enlace: $SERVER"
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=120000 \
            --congestion-control=cubic \
            --gso=false > "$LOG_FILE" 2>&1 &
        
        # Espera 7 segundos para confirmar
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                clear
                echo "========================================="
                echo "    [✓] CONEXIÓN VIP ESTABLECIDA"
                echo "========================================="
                echo " DNS: $SERVER"
                echo "-----------------------------------------"
                echo "1. Abre HTTP Custom"
                echo "2. Activa BYPASS para Termux (Vital)"
                echo "3. SSH: 127.0.0.1 Puerto: 5201"
                echo "-----------------------------------------"
                echo "Presiona Ctrl+C para desconectar"
                wait
                return
            fi
            sleep 1
        done
        clean
    done
    echo "[X] No se pudo conectar. Reintenta en unos instantes."
    read -p "Presiona ENTER para volver"
}

# Menú Principal Visual
setup
while true; do
    clear
    echo "  ██╗   ██╗██╗██████╗ "
    echo "  ██║   ██║██║██╔══██╗"
    echo "  ██║   ██║██║██████╔╝"
    echo "  ╚██╗ ██╔╝██║██╔═══╝ "
    echo "   ╚████╔╝ ██║██║     "
    echo "    ╚═══╝  ╚═╝╚═╝     "
    echo "   --- SERVICIO PREMIUM ---"
    echo "-----------------------------------------"
    echo " 1) CONECTAR (DATOS MÓVILES)"
    echo " 2) CONECTAR (WIFI)"
    echo " 0) SALIR"
    echo "-----------------------------------------"
    read -p " Selección: " opt
    case $opt in
        1) connect "200.55.128.130:53" "200.55.128.140:53" "200.55.128.230:53" "200.55.128.250:53" ;;
        2) connect "181.225.231.120:53" "181.225.231.110:53" "181.225.233.40:53" "181.225.233.30:53" ;;
        0) clean; exit ;;
    esac
done
