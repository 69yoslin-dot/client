#!/data/data/com.termux/files/usr/bin/bash

clear
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

### ===============================
### COMPROBAR / INSTALAR DIALOG
### ===============================
if ! command -v dialog >/dev/null 2>&1; then
    pkg update -y >/dev/null 2>&1
    pkg install dialog -y >/dev/null 2>&1
fi

MODE=$(command -v dialog >/dev/null 2>&1 && echo "DIALOG" || echo "TEXT")

### ===============================
### BIENVENIDA SS.MADARAS
### ===============================
if [ "$MODE" = "DIALOG" ]; then
    dialog --msgbox "Bienvenido al instalador VIP de SS.MADARAS.\n\nSe configurará tu terminal para el túnel DNS." 10 55
else
    echo -e "\nBienvenido al instalador VIP de SS.MADARAS.\n"
fi

### ===============================
### INSTALACIÓN
### ===============================
install_logic() {
    echo 20; pkg update -y >/dev/null 2>&1
    echo 40; pkg upgrade -y >/dev/null 2>&1
    echo 60; pkg install wget brotli openssl termux-tools dos2unix -y >/dev/null 2>&1
    echo 80; wget -q https://raw.githubusercontent.com/Mahboub-power-is-back/quic_over_dns/main/slipstream-client
    echo 90; chmod +x slipstream-client
    echo 100
}

if [ "$MODE" = "DIALOG" ]; then
    install_logic | dialog --gauge "Instalando herramientas SS.MADARAS..." 10 60 0
else
    install_logic
fi

clear
echo -e "Instalación completada correctamente."
echo -e "Soporte Telegram: https://t.me/ss_madaras"
