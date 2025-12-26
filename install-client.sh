#!/data/data/com.termux/files/usr/bin/bash

clear
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

if [ ! -d "/data/data/com.termux" ]; then
    echo "[!] Este script solo funciona en Termux."
    exit 1
fi

if ! command -v dialog >/dev/null 2>&1; then
    pkg update -y && pkg install dialog -y
fi

MODE="DIALOG"
[[ ! $(command -v dialog) ]] && MODE="TEXT"

msg() { [ "$MODE" = "DIALOG" ] && dialog --msgbox "$1" 10 55 || echo -e "\n$1\n"; }

confirm() {
    if [ "$MODE" = "DIALOG" ]; then
        dialog --yesno "$1" 8 45
        return $?
    else
        read -p "$1 (y/n): " r
        [[ "$r" =~ ^[Yy]$ ]]
    fi
}

msg "Bienvenido al instalador SS.MADARAS.\n\nSe configurará el cliente para: freezing-dns.duckdns.org"

confirm "¿Deseas continuar?"
[ $? -ne 0 ] && clear && exit 1

install_with_progress() {
    echo 10; pkg update -y >/dev/null 2>&1
    echo 30; pkg upgrade -y >/dev/null 2>&1
    echo 50; pkg install wget brotli openssl openssl-tool termux-tools iproute2 -y >/dev/null 2>&1
    echo 70; wget -q -O slipstream-client https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
    echo 90; chmod +x slipstream-client
    echo 100
}

if [ "$MODE" = "DIALOG" ]; then
    install_with_progress | dialog --gauge "Instalando herramientas..." 10 60 0
else
    install_with_progress
fi

# Mensaje final con el dominio correcto
if [ "$MODE" = "DIALOG" ]; then
    dialog --clear --title "SS.MADARAS" \
        --msgbox "Instalación completada.\n\nDominio: freezing-dns.duckdns.org\nPuerto local: 5201\n\nYa puedes ejecutar setup.sh" 12 50
else
    echo -e "\nInstalación completa. Dominio: freezing-dns.duckdns.org"
fi
clear
