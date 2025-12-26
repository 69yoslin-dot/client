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
### BIENVENIDA
### ===============================
msg "Bienvenido al instalador VIP de SS.MADARAS.\n\nSe instalarán todas las herramientas necesarias para la conexión DNS."

confirm "¿Deseas continuar?"
[ $? -ne 0 ] && clear && exit 1

### ===============================
### CONFIGURAR REPOS
### ===============================
if [ "$MODE" = "DIALOG" ]; then
    dialog --infobox "Configurando repositorios y actualizando...\n\nPor favor espera." 6 50
    pkg update -y >/dev/null 2>&1
else
    pkg update -y
fi

### ===============================
### INSTALACIÓN CON PROGRESO
### ===============================
install_with_progress() {
    echo 20
    pkg upgrade -y >/dev/null 2>&1

    echo 40
    pkg install wget brotli openssl termux-tools dos2unix -y >/dev/null 2>&1

    echo 70
    # Descarga directa del cliente corregido
    wget -q -O slipstream-client https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client

    echo 90
    chmod +x slipstream-client
    
    echo 100
}

if [ "$MODE" = "DIALOG" ]; then
    install_with_progress | dialog --gauge "Instalando herramientas SS.MADARAS VIP..." 10 60 0
else
    install_with_progress
fi

### ===============================
### FINALIZACIÓN
### ===============================
final_message() {
    local TELEGRAM_CHAT="https://t.me/ss_madaras"
    if [ "$MODE" = "DIALOG" ]; then
        choice=$(dialog --clear --title "SS.MADARAS VIP" \
            --menu "Instalación completada.\n\nDominio: dns.freezing.work.gd\nPuerto local: 5201" 12 50 2 \
            1 "FINALIZAR" \
            2 "SOPORTE TELEGRAM" 3>&1 1>&2 2>&3)
        [[ "$choice" == "2" ]] && am start -a android.intent.action.VIEW -d "$TELEGRAM_CHAT"
    else
        echo -e "\nInstalación completa. Dominio configurado: dns.freezing.work.gd"
    fi
}

final_message
clear

