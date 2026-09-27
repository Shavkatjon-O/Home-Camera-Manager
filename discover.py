import re
import socket
import sys
import time
import uuid


def local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("192.168.1.1", 9))
    ip = s.getsockname()[0]
    s.close()
    return ip


def collect(sock, seconds):
    seen = {}
    t0 = time.time()
    while time.time() - t0 < seconds:
        try:
            data, addr = sock.recvfrom(65535)
        except socket.timeout:
            break
        seen[addr[0]] = data.decode(errors="ignore")
    return seen


def probe(bind_ip, port, targets, payload, bind_port=0):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
    s.bind((bind_ip, bind_port))
    s.settimeout(3)
    for _ in range(3):
        for t in targets:
            s.sendto(payload.encode(), (t, port))
    found = collect(s, 5)
    s.close()
    return found


def sadp(bind_ip):
    payload = (
        '<?xml version="1.0" encoding="utf-8"?><Probe><Uuid>%s</Uuid>'
        "<Types>inquiry</Types></Probe>" % str(uuid.uuid4()).upper()
    )
    found = probe(bind_ip, 37020, ["239.255.255.250", "255.255.255.255"], payload, 37020)
    rows = []
    for ip, xml in sorted(found.items()):
        row = {"ip": ip}
        for key in ("DeviceDescription", "DeviceSN", "MAC", "SoftwareVersion", "DHCP"):
            m = re.search(r"<%s>([^<]*)<" % key, xml)
            row[key] = m.group(1) if m else ""
        rows.append(row)
    return rows


def onvif(bind_ip):
    payload = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<e:Envelope xmlns:e="http://www.w3.org/2003/05/soap-envelope" '
        'xmlns:w="http://schemas.xmlsoap.org/ws/2004/08/addressing" '
        'xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" '
        'xmlns:dn="http://www.onvif.org/ver10/network/wsdl">'
        "<e:Header><w:MessageID>uuid:%s</w:MessageID>"
        '<w:To e:mustUnderstand="true">urn:schemas-xmlsoap-org:ws:2005:04:discovery</w:To>'
        '<w:Action e:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</w:Action>'
        "</e:Header><e:Body><d:Probe><d:Types>dn:NetworkVideoTransmitter</d:Types></d:Probe></e:Body></e:Envelope>"
        % uuid.uuid4()
    )
    found = probe(bind_ip, 3702, ["239.255.255.250"], payload)
    rows = []
    for ip, xml in sorted(found.items()):
        hw = re.search(r"onvif://www\.onvif\.org/hardware/([^ <]*)", xml)
        mac = re.search(r"onvif://www\.onvif\.org/MAC/([^ <]*)", xml)
        rows.append({"ip": ip, "hardware": hw.group(1) if hw else "", "mac": mac.group(1) if mac else ""})
    return rows


def rtsp_open(ip):
    s = socket.socket()
    s.settimeout(3)
    try:
        s.connect((ip, 554))
        return True
    except OSError:
        return False
    finally:
        s.close()


def main():
    bind_ip = sys.argv[1] if len(sys.argv) > 1 else local_ip()
    print("probing from", bind_ip)
    for row in sadp(bind_ip):
        print("sadp ", row["ip"], row["DeviceDescription"], row["DeviceSN"], row["MAC"], row["SoftwareVersion"], "rtsp" if rtsp_open(row["ip"]) else "no-rtsp")
    for row in onvif(bind_ip):
        print("onvif", row["ip"], row["hardware"], row["mac"], "rtsp" if rtsp_open(row["ip"]) else "no-rtsp")


if __name__ == "__main__":
    main()
