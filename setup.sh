#!/data/data/com.termux/files/usr/bin/bash

clear

# Configuración Maestra (ACTUALIZADO A DUCKDNS)
DOMAIN="freezing-dns.duckdns.org"
ACTIVE_DNS="No conectado"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
mkdir -p "$LOG_DIR"

# Servidores DNS ETECSA (Cuba)
DATA_SERVERS=("200.55.128.130:53" "200.55.128.140:53" "200.55.128.230:53" "200.55.128.250:53")
WIFI_SERVERS=("181.225.231.120:53" "181.225.231.110:53" "181.225.233.40:53" "181.225.233.30:53")

detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATA"
}

clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

connect_auto() {
    local SERVERS=("$@")
    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"
        clear
        echo -e "\e[1;34m[*] SS.MADARAS PROBANDO: $SERVER\e[0m"

        # Ejecución del cliente
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=20 \
            > "$LOG_FILE" 2>&1 &

        # Detección de conexión exitosa
        for i in {1..12}; do
            # Buscamos la señal de éxito en el log
            if grep -qE "Connection confirmed|assigned stream id|Stream opened" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                echo -e "\e[1;32m████████████████████████████████"
                echo -e "[✓] SS.MADARAS: CONEXIÓN EXITOSA"
                echo -e "[✓] DNS Activo: $ACTIVE_DNS"
                echo -e "[✓] Dominio: $DOMAIN"
                echo -e "████████████████████████████████\e[0m"
                echo -e "\n\e[1;37mPASO FINAL: Abre HTTP Custom y conecta a 127.0.0.1:5201\e[0m"
                echo -e "\nEscriba 'menu' para desconectar."
                
                while true; do
                    read -p "> " cmd
                    [[ "$cmd" == "menu" ]] && clean_slipstream && ACTIVE_DNS="No conectado" && return
                done
            fi
            sleep 1
        done
        clean_slipstream
    done
    echo -e "\e[1;31m[X] Error en todos los servidores. Revisa tu VPS o certificados.\e[0m"
    read -p "ENTER para volver"
}

while true; do
    clear
    NET=$(detect_network)
    [[ "$NET" == "DATA" ]] && { D="●"; W="○"; } || { D="○"; W="●"; }

    echo -e "\e[1;34m███████╗███████╗    ███╗   ███╗██████╗ "
    echo -e "██╔════╝██╔════╝    ████╗ ████║██╔══██╗"
    echo -e "███████╗███████╗    ██╔████╔██║██║  ██║"
    echo -e "╚════██║╚════██║    ██║╚██╔╝██║██║  ██║"
    echo -e "███████║███████║    ██║ ╚═╝ ██║██████╔╝"
    echo -e "╚══════╝╚══════╝    ╚═╝     ╚═╝╚═════╝\e[0m"
    echo -e "      \e[1;32mESTADO: $ACTIVE_DNS\e[0m\n"
    echo -e "$D 1) Conectar Datos Móviles (ETECSA)"
    echo -e "$W 2) Conectar WiFi (ETECSA)"
    echo -e "   3) Reinstalar Cliente"
    echo -e "   0) Salir"
    echo
    read -p "Opción: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) bash install-client.sh ;;
        0) clean_slipstream; exit ;;
    esac
done
