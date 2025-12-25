#!/data/data/com.termux/files/usr/bin/bash

clear
# Datos de tu VPS AlexHost
DOMAIN="dns.freezing.work.gd"
ACTIVE_DNS="No conectado"
LOG_FILE="$HOME/.slipstream/slip.log"
mkdir -p "$HOME/.slipstream"

# Servidores DNS ETECSA
DATA_SERVERS=("200.55.128.130:53" "200.55.128.140:53" "200.55.128.230:53" "200.55.128.250:53")
WIFI_SERVERS=("181.225.231.120:53" "181.225.231.110:53" "181.225.233.40:53" "181.225.233.30:53")

detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATA"
}

# Aquí es donde el nombre cambia para coincidir con tu GitHub
install_slipstream() {
    clear
    pkg install wget -y
    # Reemplaza '69yoslin-dot' por tu usuario real si es diferente
    wget https://raw.githubusercontent.com/69yoslin-dot/client/main/install-client.sh
    chmod +x install-client.sh
    ./install-client.sh
    read -p "ENTER para volver al menú"
}

clean_slip() { pkill -f slipstream-client 2>/dev/null; sleep 1; }

connect_auto() {
    local SERVERS=("$@")
    for SERVER in "${SERVERS[@]}"; do
        clean_slip
        clear
        echo "[*] SS.MADARAS Probando: $SERVER"
        ./slipstream-client --tcp-listen-port=5201 --resolver="$SERVER" --domain="$DOMAIN" --keep-alive-interval=600 > "$LOG_FILE" 2>&1 &
        
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                echo -e "=================================="
                echo -e "    SS.MADARAS CONECTADO ✅"
                echo -e "=================================="
                echo -e "DNS: $ACTIVE_DNS"
                echo -e "Usa 127.0.0.1:5201 en HTTP Custom"
                echo -e "Escribe 'menu' para desconectar."
                
                while true; do
                    read -p "> " cmd
                    if [[ "$cmd" == "menu" ]]; then clean_slip; ACTIVE_DNS="No conectado"; return; fi
                done
            fi
            sleep 1
        done
        clean_slip
    done
    read -p "Fallo en conexión. ENTER para volver."
}

while true; do
    clear
    NET=$(detect_network)
    echo -e "SS.MADARAS VIP SYSTEM | Red: $NET"
    echo -e "DNS: $ACTIVE_DNS\n"
    echo "1) Conectar en Datos"
    echo "2) Conectar en WiFi"
    echo "3) Instalar/Reparar (install-client.sh)"
    echo "0) Salir"
    read -p "Opción: " opt
    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) install_slipstream ;;
        0) exit ;;
    esac
done
