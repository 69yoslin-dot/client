import socket
import time
import sys
import os
import random
from dnslib import DNSRecord, QTYPE

# ==========================================
# CONFIGURACIÓN ACTUALIZADA
# ==========================================
SERVER_DOMAIN = "madaras.publicvm.com"  # <--- TU NUEVO DOMINIO
MY_TELEGRAM = "https://t.me/ss_madaras"

# DNS DE ETECSA (DATOS)
DNS_DATA = [
    "200.55.128.130", "200.55.128.140", 
    "200.55.128.230", "200.55.128.250"
]

# DNS NAUTA (WIFI)
DNS_WIFI = [
    "181.225.231.120", "181.225.231.110", 
    "181.225.233.40", "181.225.233.30"
]

# COLORES
C = "\033[1;36m" # Cyan
G = "\033[1;32m" # Green
P = "\033[1;35m" # Purple
R = "\033[1;31m" # Red
W = "\033[1;37m" # White
X = "\033[0m"    # Reset

def banner():
    os.system("clear")
    print(f"{P}╔═══════════════════════════════════════╗{X}")
    print(f"{P}║      SS.MADARAS TUNNEL v3.0 (VIP)     ║{X}")
    print(f"{P}╚═══════════════════════════════════════╝{X}")
    print(f"{C} DOMINIO: {W}{SERVER_DOMAIN}{X}")
    print(f"{W}─────────────────────────────────────────{X}")

def log(tag, msg):
    now = time.strftime("%H:%M:%S")
    if tag == "OK":
        print(f"{W}[{now}] {G}RECIBIDO ✓ {X}{msg}")
    elif tag == "SEND":
        print(f"{W}[{now}] {C}ENVIANDO » {X}{msg}")
    elif tag == "FAIL":
        print(f"{W}[{now}] {R}ERROR ✗ {X}{msg}")

def start_tunnel(dns_ip):
    banner()
    print(f"{P}[*] Conectando vía DNS: {W}{dns_ip}{X}")
    print(f"{W}─────────────────────────────────────────{X}")
    
    session_id = random.randint(1000, 9999)
    seq = 0
    
    while True:
        try:
            # Generamos subdominio único para evitar caché
            # Ejemplo: p1.5599.madaras.publicvm.com
            subdomain = f"p{seq}.{session_id}.{SERVER_DOMAIN}"
            
            q = DNSRecord.q(subdomain)
            pkt = q.pack()
            
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(3) # Timeout rápido
            
            log("SEND", f"Paquete #{seq}")
            start_t = time.time()
            
            sock.sendto(pkt, (dns_ip, 53))
            response, _ = sock.recvfrom(1024)
            
            latency = (time.time() - start_t) * 1000
            
            reply = DNSRecord.parse(response)
            if reply.header.rcode == 0:
                # Buscamos si el servidor nos mandó el TXT secreto
                is_valid = False
                for rr in reply.rr:
                    if QTYPE[rr.rtype] == "TXT" and b"SS-TUNNEL-OK" in rr.rdata.data:
                        is_valid = True
                
                if is_valid or latency > 0:
                    log("OK", f"Latencia: {int(latency)}ms | Seq: {seq}")
                else:
                    log("FAIL", "Respuesta vacía o falsa")
            
            seq += 1
            time.sleep(1) # Estabilidad
            
        except socket.timeout:
            log("FAIL", "Sin respuesta del servidor")
            time.sleep(2)
        except Exception as e:
            log("FAIL", str(e))
        finally:
            try: sock.close()
            except: pass

def main():
    banner()
    print(" [1] Conexión DATOS (3G/4G)")
    print(" [2] Conexión WIFI (Etecsa)")
    print(" [0] Salir")
    print(f"{W}─────────────────────────────────────────{X}")
    opt = input(" Selecciona: ")
    
    if opt == "1": start_tunnel(random.choice(DNS_DATA))
    elif opt == "2": start_tunnel(random.choice(DNS_WIFI))
    elif opt == "0": sys.exit()
    else: main()

if __name__ == "__main__":
    main()
