import socket
import time
import sys
import os
import random
import threading
from dnslib import DNSRecord, QTYPE

# ==========================================
# CONFIGURACIÓN DEL USUARIO
# ==========================================
SERVER_DOMAIN = "freezing.2bd.net"  # Tu dominio
MY_TELEGRAM = "https://t.me/ss_madaras"
VERSION = "2.5 PREMIUM"

# LISTAS DE SERVIDORES DNS (ETECSA / WIFI)
DNS_DATA = [
    "200.55.128.130",
    "200.55.128.140",
    "200.55.128.230",
    "200.55.128.250"
]

DNS_WIFI = [
    "181.225.231.120",
    "181.225.231.110",
    "181.225.233.40",
    "181.225.233.30"
]

# ==========================================
# ESTÉTICA Y COLORES
# ==========================================
class Col:
    NEON_CYAN = '\033[1;36m'
    NEON_PURPLE = '\033[1;35m'
    NEON_GREEN = '\033[1;32m'
    RED = '\033[1;31m'
    YELLOW = '\033[1;33m'
    WHITE = '\033[1;37m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def banner():
    os.system("clear")
    print(f"{Col.NEON_PURPLE}")
    print(f"███╗   ███╗ █████╗ ██████╗  █████╗ ██████╗  █████╗ ███████╗")
    print(f"████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝")
    print(f"██╔████╔██║███████║██║  ██║███████║██████╔╝███████║███████╗")
    print(f"██║╚██╔╝██║██╔══██║██║  ██║██╔══██║██╔══██╗██╔══██║╚════██║")
    print(f"██║ ╚═╝ ██║██║  ██║██████╔╝██║  ██║██║  ██║██║  ██║███████║")
    print(f"╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝")
    print(f"{Col.NEON_CYAN}    >>> PRIVATE SERVER | BY SS.MADARAS | CUBA <<<    {Col.RESET}")
    print(f"{Col.WHITE}──────────────────────────────────────────────────────────{Col.RESET}")

# ==========================================
# LÓGICA DE CONEXIÓN
# ==========================================

def log(type, msg):
    timestamp = time.strftime("%H:%M:%S")
    if type == "INFO":
        print(f"{Col.WHITE}[{timestamp}]{Col.RESET} {msg}")
    elif type == "SEND":
        print(f"{Col.WHITE}[{timestamp}]{Col.RESET} {Col.NEON_CYAN}Enviando Paket >>{Col.RESET} {msg}")
    elif type == "RECV":
        print(f"{Col.WHITE}[{timestamp}]{Col.RESET} {Col.NEON_GREEN}Recibido << OK{Col.RESET} {msg}")
    elif type == "ERROR":
        print(f"{Col.WHITE}[{timestamp}]{Col.RESET} {Col.RED}Error:{Col.RESET} {msg}")

def tunnel_loop(dns_server):
    banner()
    print(f"{Col.YELLOW}[!] Iniciando túnel a través de: {dns_server}{Col.RESET}")
    print(f"{Col.YELLOW}[!] Servidor Destino: {SERVER_DOMAIN}{Col.RESET}")
    print(f"{Col.WHITE}──────────────────────────────────────────────────────────{Col.RESET}")
    
    # Crear un ID de sesión único
    session_id = hex(random.getrandbits(16))[2:]
    seq = 0
    
    while True:
        try:
            # Construir Query Falsa pero válida
            # Estructura: <random>.<session>.<dominio>
            # Esto evita el caché de ETECSA
            subdomain = f"p{seq}.{session_id}.{SERVER_DOMAIN}"
            
            q = DNSRecord.q(subdomain)
            dns_packet = q.pack()
            
            # Enviar paquete UDP al DNS de ETECSA (Puerto 53)
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(4) # Timeout de 4 segundos
            
            start_time = time.time()
            log("SEND", f"Query {seq} -> {dns_server}")
            
            sock.sendto(dns_packet, (dns_server, 53))
            
            # Esperar respuesta
            response, _ = sock.recvfrom(1024)
            end_time = time.time()
            
            latency = (end_time - start_time) * 1000
            
            # Decodificar respuesta básica para verificar integridad
            parsed_resp = DNSRecord.parse(response)
            if parsed_resp.header.rcode == 0: # NOERROR
                log("RECV", f"Latencia: {latency:.1f}ms | Seq: {seq}")
            else:
                log("ERROR", f"DNS Refused (RCODE: {parsed_resp.header.rcode})")

            seq += 1
            time.sleep(1) # Intervalo para no saturar y mantener estabilidad

        except socket.timeout:
            log("ERROR", "Tiempo de espera agotado (Timeout)")
            time.sleep(2)
        except Exception as e:
            log("ERROR", str(e))
            time.sleep(2)
        finally:
            sock.close()

# ==========================================
# MENÚ PRINCIPAL
# ==========================================
def main():
    while True:
        banner()
        print(f"{Col.NEON_PURPLE}[1]{Col.RESET} Conexión DATOS MÓVILES (Red 3G/4G)")
        print(f"{Col.NEON_PURPLE}[2]{Col.RESET} Conexión WIFI (Nauta/Etecsa)")
        print(f"{Col.NEON_PURPLE}[3]{Col.RESET} Soporte / Telegram")
        print(f"{Col.NEON_PURPLE}[0]{Col.RESET} Salir")
        print(f"\n{Col.WHITE}Selecciona una opción:{Col.RESET} ", end="")
        
        opt = input()
        
        if opt == "1":
            # Selección automática o manual de DNS de Datos
            target = random.choice(DNS_DATA)
            tunnel_loop(target)
        elif opt == "2":
            target = random.choice(DNS_WIFI)
            tunnel_loop(target)
        elif opt == "3":
            os.system(f"am start -a android.intent.action.VIEW -d {MY_TELEGRAM} > /dev/null 2>&1")
        elif opt == "0":
            sys.exit()
        else:
            pass

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{Col.RED}[!] Desconectando...{Col.RESET}")
        sys.exit()
