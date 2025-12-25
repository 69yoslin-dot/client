#!/data/data/com.termux/files/usr/bin/bash

clear

# === CONFIGURACION DE SS.MADARAS ===
DOMAIN="dns.freezing.work.gd"
ACTIVE_DNS="Desconectado"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"

mkdir -p "$LOG_DIR"

# DNS PARA ETECSA (No tocar si es para Cuba)
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

detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATA"
}

clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

trap_ctrl_c() {
    echo
    echo "[!] Deteniendo servicios..."
    clean_slipstream
    ACTIVE_DNS="Desconectado"
    read -p "Presiona ENTER para volver"
    return
}

wait_for_menu() {
    while true; do
        echo
        echo -n "Comando [menu]: "
        read -r input </dev/tty
        [[ -z "$input" ]] && continue
        cmd=$(echo "$input" | tr '[:upper:]' '[:lower:]')

        if [[ "$cmd" == "menu" ]]; then
            clean_slipstream
            ACTIVE_DNS="Desconectado"
            return
        fi
    done
}

connect_auto() {
    local SERVERS=("$@")

    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"
        clear
        echo "----------------------------------"
        echo "  SS.MADARAS - CONECTANDO..."
        echo "----------------------------------"
        echo "[*] Servidor DNS: $SERVER"
        echo "[*] Dominio: $DOMAIN"
        echo

        trap trap_ctrl_c INT

        # Ejecución del cliente local
        ./slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &

        # Esperar conexión (Timeout 7s)
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                echo "=================================="
                echo "    CONEXIÓN ESTABLECIDA ✅"
                echo "=================================="
                echo " IP Local: 127.0.0.1"
                echo " Puerto:   5201"
                echo " DNS:      $ACTIVE_DNS"
                echo "=================================="
                echo " Ve a HTTP Custom y conecta ahora."
                echo " Escribe 'menu' para desconectar."
                echo

                wait_for_menu
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

    echo "[!] Falló la conexión con los servidores disponibles."
    read -p "ENTER para continuar"
}

while true; do
    clear
    NET=$(detect_network)
    DATA_MARK="[ ]"
    WIFI_MARK="[ ]"
    [[ "$NET" == "DATA" ]] && DATA_MARK="[ON]"
    [[ "$NET" == "WIFI" ]] && WIFI_MARK="[ON]"

    echo " ______________________________ "
    echo "|                              |"
    echo "|      SS.MADARAS SYSTEM       |"
    echo "|______________________________|"
    echo "| User: SS.MADARAS             |"
    echo "| Host: $DOMAIN |"
    echo "|______________________________|"
    echo
    echo " Estado: $ACTIVE_DNS"
    echo
    echo " $DATA_MARK 1. Conexión Datos Móviles"
    echo " $WIFI_MARK 2. Conexión WiFi"
    echo "      0. Salir"
    echo
    echo " Telegram: https://t.me/ss_madaras"
    echo "______________________________"
    read -p " Elige opción: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        0) clean_slipstream; exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
