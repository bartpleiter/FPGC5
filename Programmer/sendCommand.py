#!/usr/bin/env python3

# tool to send commands to the FPGC
# eg: echo "clear" | python3 sendCommand.py

import socket
import sys
from time import sleep

data = sys.stdin.read()

if len(data) == 0:
    print("Empty data")
    exit(1)

# init connection
s = socket.socket()
port = 3222

for idx, attempt in enumerate(range(10)):
    try:
        s.connect(("192.168.0.213", port))

        bdata = data.encode()
        s.send(bdata)
        s.recv(len(bdata))
    except:
        sleep(0.1)
    else:
        break
    if idx == 9:
        print("ERROR: could not send", data)


# close socket when done
s.close()