#!/bin/bash

# ==================================================
#  SS.MADARAS - SERVER INSTALLER (FREEZING DNS)
#  Optimizado para Debian 11 / 12
# ==================================================

# --- COLORES ---
PURPLE='\033[38;5;93m'
CYAN='\033[38;5;51m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;226m'
WHITE='\033[1;37m'
RESET='\033[0m'

# --- CONFIGURACIÓN ---
DOMAIN="dns.madaras.work.gd"
BIN_URL="https://github.com/Mahboub-power-is-back/quic_over_dns/raw/main/slipstream-server-linux-amd64"

header() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${PURPLE}║${WHITE}       SS.MADARAS SERVER INSTALLER v1.0       ${PURPLE}║${RESET}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════╝${RESET}"
}

echo -e "${YELLOW}[*] Iniciando instalación profesional...${RESET}"

# --- 0. LIMPIEZA TOTAL ---
echo -e "${CYAN}[1/7] Limpiando conflictos previos...${RESET}"
systemctl stop slipstream 2>/dev/null
pkill -9 slipstream-serv 2>/dev/null
pkill -9 slipstream-server 2>/dev/null
fuser -k 53/udp 2>/dev/null
fuser -k 53/tcp 2>/dev/null
apt update && apt install -y wget openssl psmisc iptables > /dev/null 2>&1

# --- 1. FORWARDING ---
echo -e "${CYAN}[2/7] Configurando IPv4 Forwarding...${RESET}"
sysctl -w net.ipv4.ip_forward=1 > /dev/null
sed -i '/net.ipv4.ip_forward=1/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# --- 2. NAT & IPTABLES ---
echo -e "${CYAN}[3/7] Aplicando reglas de red (Internet)...${RESET}"
IFACE=$(ip route | grep default | awk '{print $5}')
iptables -t nat -F
iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
iptables -A FORWARD -i $IFACE -o $IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# --- 3. SSH TUNNEL OPTIMIZATION ---
echo -e "${CYAN}[4/7] Optimizando SSH para túneles...${RESET}"
sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sed -i 's/^#*GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitTunnel.*/PermitTunnel yes/' /etc/ssh/sshd_config
systemctl restart ssh

# --- 4. BINARIO Y CERTIFICADOS ---
echo -e "${CYAN}[5/7] Descargando binario y generando SSL...${RESET}"
wget -q -O /root/slipstream-server "$BIN_URL"
chmod +x /root/slipstream-server

mkdir -p /root/certs
if [ ! -f /root/certs/cert.pem ]; then
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj "/CN=$DOMAIN" \
        -keyout /root/certs/key.pem \
        -out /root/certs/cert.pem > /dev/null 2>&1
    chmod 600 /root/certs/key.pem
fi

# --- 5. SYSTEMD SERVICE ---
echo -e "${CYAN}[6/7] Creando servicio Slipstream...${RESET}"
cat << SERVICE > /etc/systemd/system/slipstream.service
[Unit]
Description=Slipstream DNS Tunnel
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStartPre=/bin/chmod +x /root/slipstream-server
ExecStart=/root/slipstream-server --target-address=127.0.0.1:22 --domain=$DOMAIN --cert=/root/certs/cert.pem --key=/root/certs/key.pem --dns-listen-port=53
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl stop systemd-resolved 2>/dev/null
systemctl disable systemd-resolved 2>/dev/null
systemctl daemon-reload
systemctl enable slipstream > /dev/null 2>&1
systemctl start slipstream

# --- 6. GESTOR DE USUARIOS INTEGRADO ---
echo -e "${CYAN}[7/7] Instalando Panel de Gestión...${RESET}"
cat << 'MGR' > /root/manager.sh
#!/bin/bash
while true; do
    clear
    echo -e "\033[38;5;93m╔══════════════════════════════════════════╗\033[0m"
    echo -e "\033[38;5;93m║       SS.MADARAS | PANEL DE CONTROL      ║\033[0m"
    echo -e "\033[38;5;93m╚══════════════════════════════════════════╝\033[0m"
    echo -e " [1] Crear Usuario Nuevo"
    echo -e " [2] Eliminar Usuario"
    echo -e " [3] Listar Usuarios / Expiración"
    echo -e " [4] Ver Logs de Conexión"
    echo -e " [0] Salir"
    echo -ne "\n Opción: "
    read opt
    case $opt in
        1) read -p "User: " u; read -p "Pass: " p; read -p "Días: " d;
           exp=$(date -d "+$d days" +%Y-%m-%d); useradd -m -e "$exp" -s /bin/false "$u";
           echo "$u:$p" | chpasswd; echo -e "\e[32mCreado hasta $exp\e[0m"; sleep 2 ;;
        2) read -p "User a borrar: " u; userdel -r "$u"; echo "Borrado"; sleep 2 ;;
        3) clear; printf "\e[36m%-15s | %-15s\e[0m\n" "USUARIO" "EXPIRACIÓN";
           echo "-------------------------------";
           while IFS=: read -r u p uid g i h s; do
           [ "$uid" -ge 1000 ] && [ "$u" != "nobody" ] && printf "%-15s | %s\n" "$u" "$(chage -l "$u" | grep "Account expires" | cut -d: -f2)";
           done < /etc/passwd; read -p "Enter para volver..." ;;
        4) journalctl -u ssh -f ;;
        0) break ;;
    esac
done
MGR
chmod +x /root/manager.sh

header
echo -e "${GREEN}${BOLD}      ¡CONFIGURACIÓN COMPLETADA CON ÉXITO!${RESET}"
echo -e "${PURPLE} ────────────────────────────────────────────────${RESET}"
echo -e "${WHITE}  » Dominio : ${CYAN}$DOMAIN"
echo -e "${WHITE}  » Gestión : ${YELLOW}./manager.sh"
echo -e "${PURPLE} ────────────────────────────────────────────────${RESET}"
echo -e "${GREY} Verificando estado del servicio...${RESET}"
sleep 2
systemctl status slipstream --no-pager
