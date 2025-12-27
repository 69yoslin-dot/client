#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#  CONECTOR CLIENTE - SS_MADARAS
# ==========================================

clear

# --- CONFIGURACIÓN DEL SERVIDOR ---
DOMAIN="freezing-dns.duckdns.org"  # TU DOMINIO REAL
LOCAL_PORT="5201"                  # Puerto local para HTTP Custom
LOG_DIR="$HOME/.ss_madaras"
LOG_FILE="$LOG_DIR/connection.log"

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# --- LISTAS DE SERVIDORES DNS (ETECSA/CUBACELL) ---
# Estas IPs son las puertas de enlace DNS internas
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

# --- DETECTAR RED ---
detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "WIFI" || echo "DATOS"
}

# --- LIMPIEZA DE PROCESOS ---
clean_env() {
    pkill -f slipstream-client 2>/dev/null
}

# --- MANEJO DE SEÑALES (CTRL+C) ---
trap_ctrl_c() {
    echo -e "\n\033[1;31m[!] Deteniendo servicios...\033[0m"
    clean_env
    echo -e "\033[1;33mPresiona ENTER para volver al menú\033[0m"
    return
}

# --- ESPERAR COMANDO DEL USUARIO ---
wait_for_menu() {
    while true; do
        echo
        echo -n -e "\033[1;36m(escribe 'menu' para volver) > \033[0m"
        read -r input </dev/tty
        [[ -z "$input" ]] && continue
        cmd=$(echo "$input" | tr '[:upper:]' '[:lower:]')
        if [[ "$cmd" == "menu" ]]; then
            clean_env
            return
        fi
    done
}

# --- LÓGICA DE CONEXIÓN ---
connect_auto() {
    local SERVERS=("$@")
    
    for SERVER in "${SERVERS[@]}"; do
        clean_env
        > "$LOG_FILE" # Limpiar log

        clear
        echo -e "\033[1;33m[*] Intentando conectar vía DNS...\033[0m"
        echo -e "Target: \033[1;32m$DOMAIN\033[0m"
        echo -e "DNS Server: \033[1;35m$SERVER\033[0m"
        echo -e "Puerto Local: \033[1;36m$LOCAL_PORT\033[0m"
        echo "------------------------------------------------"
        echo "Espere, estableciendo túnel..."
        echo

        trap trap_ctrl_c INT

        # EJECUCIÓN DEL CLIENTE
        # Nota: El binario debe estar en path o en carpeta actual. 
        # El setup lo pone en $PREFIX/bin, así que lo llamamos directo.
        if [ -f "$PREFIX/bin/slipstream-client" ]; then
            BIN="$PREFIX/bin/slipstream-client"
        else
            # Fallback por si no usaron el setup
            BIN="./slipstream-client"
        fi

        $BIN \
            --tcp-listen-port=$LOCAL_PORT \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=60 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &

        PID=$!

        # BUCLE DE VERIFICACIÓN (7 segundos)
        for i in {1..7}; do
            # Verificar éxito
            if grep -q "Connection confirmed" "$LOG_FILE" || grep -q "quic session opened" "$LOG_FILE"; then
                clear
                echo -e "\033[1;32m████████████████████████████████████████\033[0m"
                echo -e "\033[1;32m█      ¡CONEXIÓN ESTABLECIDA!          █\033[0m"
                echo -e "\033[1;32m████████████████████████████████████████\033[0m"
                echo
                echo -e "Server:   \033[1;37m$DOMAIN\033[0m"
                echo -e "DNS IP:   \033[1;33m$SERVER\033[0m"
                echo -e "Estado:   \033[1;32mONLINE (Tunnel Activo)\033[0m"
                echo
                echo -e "\033[1;36m>> AHORA CONECTA HTTP CUSTOM <<\033[0m"
                echo -e "   IP: 127.0.0.1  |  Puerto: $LOCAL_PORT"
                echo
                echo -e "\033[0;31m[ Presiona Ctrl + C para desconectar ]\033[0m"
                echo -e "O escribe 'menu' para salir."

                wait_for_menu
                trap - INT
                return
            fi

            # Verificar fallo inmediato
            if grep -q "Connection closed" "$LOG_FILE" || grep -q "Handshake failed" "$LOG_FILE"; then
                echo -e "\033[0;31m[x] Falló handshake con $SERVER\033[0m"
                break
            fi
            sleep 1
        done

        trap - INT
        clean_env
    done

    echo
    echo -e "\033[1;31m[!] No se pudo conectar con ningún servidor DNS.\033[0m"
    echo "Verifica tu señal o intenta cambiar entre WiFi/Datos."
    read -p "Presiona ENTER para volver al menú"
}

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    NET=$(detect_network)
    
    # Indicadores visuales
    STATUS_D=" "
    STATUS_W=" "
    [[ "$NET" == "DATOS" ]] && STATUS_D=" [ACTIVO]"
    [[ "$NET" == "WIFI" ]] && STATUS_W=" [ACTIVO]"

    # BANNER SS_MADARAS
    echo -e "\033[1;34m"
    echo "   _____ _____   __  __          _____           "
    echo "  / ____/ ____| |  \/  |   /\   |  __ \   /\     "
    echo " | (___| (___   | \  / |  /  \  | |  | | /  \    "
    echo "  \___ \\___ \  | |\/| | / /\ \ | |  | |/ /\ \   "
    echo "  ____) |___) | | |  | |/ ____ \| |__| / ____ \  "
    echo " |_____/_____/  |_|  |_/_/    \_\_____/_/    \_\ "
    echo "           SERVER PRIVATE EDITION v2.0           "
    echo -e "\033[0m"
    
    echo -e "\033[1;37mUsuario: SS_MADARAS\033[0m"
    echo -e "\033[1;37mTelegram: @internet_gratis_canal\033[0m"
    echo "------------------------------------------------"
    echo -e "Red detectada: \033[1;33m$NET\033[0m"
    echo
    echo -e "\033[1;32m1.\033[0m Conectar DNS (Datos Móviles)$STATUS_D"
    echo -e "\033[1;32m2.\033[0m Conectar DNS (WiFi ETECSA)$STATUS_W"
    echo -e "\033[1;32m3.\033[0m Ver Logs de conexión"
    echo -e "\033[1;31m0. Salir\033[0m"
    echo
    read -p " Selecciona una opción: " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) 
           clear
           echo "--- ÚLTIMOS LOGS ---"
           tail -n 20 "$LOG_FILE"
           read -p "Enter para volver"
           ;;
        0) clear; exit ;;
        *) ;;
    esac
done
