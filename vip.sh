#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURACIÓN VIP ---
DOMAIN="freezing-dns.duckdns.org"
# -------------------------

LOG_FILE="$HOME/.slip.log"

# Limpieza total de procesos
clean() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

# Instalación automática para clientes nuevos
setup() {
    if [ ! -f "./slipstream-client" ]; then
        clear
        echo "   --- INSTALADOR VIP ---"
        echo "[*] Preparando herramientas necesarias..."
        pkg update -y >/dev/null 2>&1
        pkg install wget dos2unix -y >/dev/null 2>&1
        
        echo "[*] Descargando motor de conexión..."
        wget -q https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
        chmod +x slipstream-client
        
        echo "[✓] Todo listo para conectar."
        sleep 2
    fi
}

# Lógica de conexión automática (Afinada)
connect() {
    local SERVERS=("$@")
    clean
    for SERVER in "${SERVERS[@]}"; do
        echo "[*] Probando enlace: $SERVER"
        
        # Parámetros optimizados según las pistas de Tito y Carlos
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=120000 \
            --congestion-control=cubic \
            --gso=false > "$LOG_FILE" 2>&1 &
        
        # Tiempo de espera para confirmación de ETECSA
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                clear
                echo "========================================="
                echo "      [✓] CONEXIÓN VIP ACTIVA"
                echo "========================================="
                echo " DNS RESPONDIDO: $SERVER"
                echo "-----------------------------------------"
                echo " PASOS PARA NAVEGAR:"
                echo " 1. Abre HTTP Custom"
                echo " 2. Ve a 'Proxified Apps' y marca 'Termux'"
                echo " 3. Activa el 'Bypass Mode' (Interruptor verde)"
                echo " 4. SSH: 127.0.0.1 Puerto: 5201"
                echo "-----------------------------------------"
                echo "Presiona Ctrl+C para detener el túnel"
                wait
                return
            fi
            sleep 1
        done
        clean
    done
    echo "[X] No se pudo conectar. Cambia de DNS o reintenta."
    read -p "ENTER para volver"
}

# Menú Visual
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
    echo " Red detectada: $(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')"
    echo "-----------------------------------------"
    echo " 1) CONECTAR (DATOS MÓVILES)"
    echo " 2) CONECTAR (WIFI)"
    echo " 0) SALIR"
    echo "-----------------------------------------"
    read -p " Opción: " opt
    case $opt in
        1) connect "200.55.128.130:53" "200.55.128.140:53" "200.55.128.230:53" "200.55.128.250:53" ;;
        2) connect "181.225.231.120:53" "181.225.231.110:53" "181.225.233.40:53" "181.225.233.30:53" ;;
        0) clean; exit ;;
    esac
done
