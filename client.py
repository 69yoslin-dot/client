import socket
import time
import sys
import os
import random
from dnslib import DNSRecord, QTYPE, DNSQuestion

# ==========================================
# CONFIGURACIÓN MADARAS VIP
# ==========================================
SERVER_DOMAIN = "madaras.publicvm.com"
TIMEOUT_DNS = 3  # Segundos antes de saltar al siguiente DNS

DNS_DATA = ["200.55.128.130", "200.55.128.140", "200.55.128.230", "200.55.128.250"]
DNS_WIFI = ["181.225.231.120", "181.225.231.110", "181.225.233.40", "181.225.233.30"]

C, G, P, R, Y, W, X = "\033[1;36m", "\033[1;32m", "\033[1;35m", "\033[1;31m", "\033[1;33m", "\033[1;37m", "\033[0m"

def banner():
    os.system("clear")
    print(f"{P}╔═══════════════════════════════════════╗{X}")
    print(f"{P}║      SS.MADARAS - AUTO CONNECT        ║{X}")
    print(f"{P}╚═══════════════════════════════════════╝{X}")
    print(f"{C} DOMINIO: {W}{SERVER_DOMAIN}{X}")
    print(f"{W}─────────────────────────────────────────{X}")

def log(tag, msg):
    now = time.strftime("%H:%M:%S")
    if tag == "OK": print(f"{W}[{now}] {G}CONECTADO ✓ {X}{msg}")
    elif tag == "TRY": print(f"{W}[{now}] {Y}PROBANDO » {X}{msg}")
    elif tag == "FAIL": print(f"{W}[{now}] {R}FALLO ✗ {X}{msg}")

def start_tunnel(dns_list):
    banner()
    connected = False
    
    while not connected:
        for dns_ip in dns_list:
            log("TRY", f"Servidor: {dns_ip}")
            
            # Intento de apretón de manos (handshake)
            session_id = random.randint(1000, 9999)
            subdomain = f"test.{session_id}.{SERVER_DOMAIN}"
            
            q_record = DNSRecord()
            q_record.add_question(DNSQuestion(subdomain, QTYPE.A))
            pkt = q_record.pack()
            
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(TIMEOUT_DNS)
            
            try:
                start_t = time.time()
                sock.sendto(pkt, (dns_ip, 53))
                response, _ = sock.recvfrom(1024)
                latency = int((time.time() - start_t) * 1000)
                
                # Si recibimos CUALQUIER respuesta DNS válida, el servidor está online
                log("OK", f"Latencia: {latency}ms en {dns_ip}")
                connected = True
                active_dns = dns_ip
                break # Salimos del for para mantener este DNS
                
            except socket.timeout:
                log("FAIL", f"Timeout en {dns_ip}")
                continue # Salta al siguiente DNS de la lista
            except Exception as e:
                log("FAIL", f"Error: {str(e)}")
            finally:
                sock.close()
        
        if not connected:
            print(f"\n{R}[!] Ningún DNS respondió. Reintentando ciclo...{X}")
            time.sleep(2)

    # Bucle de mantenimiento de conexión
    print(f"{G}\n[*] Túnel establecido mediante {active_dns}{X}")
    seq = 0
    while True:
        try:
            # Mantener el túnel vivo
            subdomain = f"p{seq}.{random.randint(100,999)}.{SERVER_DOMAIN}"
            q = DNSRecord(); q.add_question(DNSQuestion(subdomain, QTYPE.A))
            
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            sock.sendto(q.pack(), (active_dns, 53))
            sock.recvfrom(1024)
            
            print(f"{W}[{time.strftime('%H:%M:%S')}] {C}KEEP-ALIVE » {X}Paquete #{seq}", end='\r')
            seq += 1
            time.sleep(2)
        except:
            print(f"\n{R}[!] Conexión perdida con {active_dns}. Reconectando...{X}")
            start_tunnel(dns_list) # Reinicio recursivo
            break

def main():
    banner()
    print(" [1] Conectar en Datos Móviles (Auto-Scan)")
    print(" [2] Conectar en WiFi (Auto-Scan)")
    print(" [0] Salir")
    print(f"{W}─────────────────────────────────────────{X}")
    opt = input(" Selecciona: ")
    if opt == "1": start_tunnel(DNS_DATA)
    elif opt == "2": start_tunnel(DNS_WIFI)
    elif opt == "0": sys.exit()
    else: main()

if __name__ == "__main__":
    main()
