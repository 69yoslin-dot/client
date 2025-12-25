#!/data/data/com.termux/files/usr/bin/bash

clear
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

### ===============================
### COMPROBAR TERMUX
### ===============================
if [ ! -d "/data/data/com.termux" ]; then
    echo "[!] Este script solo funciona en Termux."
    exit 1
fi

### ===============================
### COMPROBAR / INSTALAR DIALOG
### ===============================
if ! command -v dialog >/dev/null 2>&1; then
    pkg update -y >/dev/null 2>&1
    pkg install dialog -y >/dev/null 2>&1
fi

if command -v dialog >/dev/null 2>&1; then
    MODE="DIALOG"
else
    MODE="TEXT"
fi

### ===============================
### FUNCIONES UI
### ===============================
msg() {
    if [ "$MODE" = "DIALOG" ]; then
        dialog --msgbox "$1" 10 55
    else
        echo -e "\n$1\n"
    fi
}

confirm() {
    if [ "$MODE" = "DIALOG" ]; then
        dialog --yesno "$1" 8 45
        return $?
    else
        read -p "$1 (y/n): " r
        [[ "$r" =~ ^[Yy]$ ]]
    fi
}

### ===============================
### BIENVENIDA SS.MADARAS
### ===============================
msg "Bienvenido al instalador de SS.MADARAS.\n\nSe configurará tu entorno Termux."

confirm "¿Deseas continuar con la instalación?"
[ $? -ne 0 ] && clear && exit 1

### ===============================
### CONFIGURAR REPOS
### ===============================
if [ "$MODE" = "DIALOG" ]; then
    dialog --infobox "Optimizando repositorios...\n\nPor favor espera." 6 50
    sleep 1
    termux-change-repo
else
    termux-change-repo
fi

### ===============================
### INSTALACIÓN
### ===============================
install_with_progress() {
    echo 10
    pkg update -y >/dev/null 2>&1

    echo 25
    pkg upgrade -y >/dev/null 2>&1

    echo 40
    pkg install wget brotli openssl termux-tools dos2unix -y >/dev/null 2>&1

    echo 60
    # AQUI DEBES PONER EL LINK RAW DE TU GITHUB DONDE SUBAS EL CLIENTE
    # Ejemplo: https://raw.githubusercontent.com/TuUsuario/TuRepo/main/slipstream-client
    wget -q https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client -O slipstream-client
    
    # Descargar el script del menú (asumiendo que lo subiste como menu.sh)
    # wget -q https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/menu.sh -O menu.sh

    echo 85
    chmod +x slipstream-client
    # chmod +x menu.sh

    echo 100
}

if [ "$MODE" = "DIALOG" ]; then
    install_with_progress | dialog --gauge "Instalando recursos SS.MADARAS..." 10 60 0
else
    install_with_progress
fi

### ===============================
### FINAL
### ===============================
final_message() {
    local TELEGRAM_CHAT="https://t.me/ss_madaras"

    if [ "$MODE" = "DIALOG" ]; then
        while true; do
            choice=$(dialog --clear --title "SS.MADARAS VIP" \
                --menu "Instalación completada." 10 50 2 \
                1 "INICIAR MENU" \
                2 "SOPORTE TELEGRAM" 3>&1 1>&2 2>&3)

            case $choice in
                1)
                    clear
                    # ./menu.sh  <-- Descomenta esto cuando subas tu menu
                    break
                    ;;
                2)
                    clear
                    am start -a android.intent.action.VIEW -d "$TELEGRAM_CHAT"
                    break
                    ;;
                *)
                    break
                    ;;
            esac
        done
    else
        echo -e "\nInstalación completada.\n"
        echo -e "Telegram: $TELEGRAM_CHAT"
    fi
}

final_message
clear
