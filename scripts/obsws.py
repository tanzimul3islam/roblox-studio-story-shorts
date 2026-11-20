"""Minimal obs-websocket v5 client, pure stdlib (no pip packages available on
this host). Supports just enough to drive recording: Identify, StartRecord,
StopRecord, GetRecordStatus, GetRecordDirectory.

Usage:
  python3 obsws.py start
  python3 obsws.py stop
  python3 obsws.py status
Socket timeout is 45 s (OBS can take >10 s to answer Start/StopRecord).
Password is read from the OBS Flatpak obs-websocket config if OBS_WS_PASSWORD is unset.
Env: OBS_WS_HOST (default 127.0.0.1), OBS_WS_PORT (default 4455),
     OBS_WS_PASSWORD (default: none / auth disabled).
"""
import base64
import hashlib
import json
import os
import socket
import struct
import sys

HOST = os.environ.get("OBS_WS_HOST", "127.0.0.1")
PORT = int(os.environ.get("OBS_WS_PORT", "4455"))
PASSWORD = os.environ.get("OBS_WS_PASSWORD", "")
if not PASSWORD:  # fall back to the Flatpak OBS websocket config on this PC
    try:
        _cfg = os.path.expanduser("~/.var/app/com.obsproject.Studio/config/obs-studio/"
                                  "plugin_config/obs-websocket/config.json")
        PASSWORD = json.load(open(_cfg)).get("server_password", "")
    except (OSError, ValueError):
        pass


def _ws_handshake(sock, host, port):
    key = base64.b64encode(os.urandom(16)).decode()
    req = (
        f"GET / HTTP/1.1\r\nHost: {host}:{port}\r\nUpgrade: websocket\r\n"
        f"Connection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n"
    )
    sock.sendall(req.encode())
    resp = b""
    while b"\r\n\r\n" not in resp:
        resp += sock.recv(4096)
    if b"101" not in resp.split(b"\r\n", 1)[0]:
        raise RuntimeError(f"handshake failed: {resp[:200]!r}")


def _send(sock, obj):
    payload = json.dumps(obj).encode()
    mask = os.urandom(4)
    masked = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
    n = len(payload)
    if n < 126:
        header = struct.pack("!BB", 0x81, 0x80 | n)
    elif n < 65536:
        header = struct.pack("!BBH", 0x81, 0x80 | 126, n)
    else:
        header = struct.pack("!BBQ", 0x81, 0x80 | 127, n)
    sock.sendall(header + mask + masked)


def _recv_frame(sock):
    def read_exact(n):
        buf = b""
        while len(buf) < n:
            chunk = sock.recv(n - len(buf))
            if not chunk:
                raise ConnectionError("socket closed")
            buf += chunk
        return buf

    head = read_exact(2)
    b1, b2 = head[0], head[1]
    opcode = b1 & 0x0F
    masked = b2 & 0x80
    length = b2 & 0x7F
    if length == 126:
        length = struct.unpack("!H", read_exact(2))[0]
    elif length == 127:
        length = struct.unpack("!Q", read_exact(8))[0]
    mask_key = read_exact(4) if masked else None
    payload = read_exact(length)
    if mask_key:
        payload = bytes(b ^ mask_key[i % 4] for i, b in enumerate(payload))
    return opcode, payload


def _recv_json(sock):
    while True:
        opcode, payload = _recv_frame(sock)
        if opcode == 0x1:  # text frame
            return json.loads(payload.decode())
        if opcode == 0x8:  # close
            raise ConnectionError("server closed connection")
        # ignore ping/pong/continuation for our simple use


def connect():
    sock = socket.create_connection((HOST, PORT), timeout=45)
    _ws_handshake(sock, HOST, PORT)
    hello = _recv_json(sock)
    auth = hello.get("d", {}).get("authentication")
    identify = {"op": 1, "d": {"rpcVersion": 1}}
    if auth:
        secret = base64.b64encode(
            hashlib.sha256((PASSWORD + auth["salt"]).encode()).digest()
        ).decode()
        auth_response = base64.b64encode(
            hashlib.sha256((secret + auth["challenge"]).encode()).digest()
        ).decode()
        identify["d"]["authentication"] = auth_response
    _send(sock, identify)
    ack = _recv_json(sock)
    if ack.get("op") != 2:
        raise RuntimeError(f"identify failed: {ack}")
    return sock


_next_id = [0]


def request(sock, req_type, req_data=None):
    _next_id[0] += 1
    rid = str(_next_id[0])
    msg = {"op": 6, "d": {"requestType": req_type, "requestId": rid}}
    if req_data is not None:
        msg["d"]["requestData"] = req_data
    _send(sock, msg)
    while True:
        resp = _recv_json(sock)
        if resp.get("op") == 7 and resp["d"]["requestId"] == rid:
            d = resp["d"]
            if not d["requestStatus"]["result"]:
                raise RuntimeError(f"{req_type} failed: {d['requestStatus']}")
            return d.get("responseData", {})


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    sock = connect()
    try:
        if cmd == "start":
            print(json.dumps(request(sock, "StartRecord")))
        elif cmd == "stop":
            print(json.dumps(request(sock, "StopRecord")))
        elif cmd == "status":
            print(json.dumps(request(sock, "GetRecordStatus")))
        elif cmd == "dir":
            print(json.dumps(request(sock, "GetRecordDirectory")))
        else:
            print(f"unknown command: {cmd}", file=sys.stderr)
            sys.exit(1)
    finally:
        sock.close()


if __name__ == "__main__":
    main()
