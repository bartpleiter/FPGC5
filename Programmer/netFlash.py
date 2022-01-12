#!/usr/bin/env python3

# Sends user program to BDOS over network.
# Program is directly written to memory.

import socket
import sys
from time import sleep

# read file to send
filename = "code.bin" #default filename to send
if len(sys.argv) >= 2:
    filename = sys.argv[1]

with open(filename, "rb") as f:
    binfile = f.read()

downloadToFile = False
outFilename = "out.abc"

# init connection
port = 3220

for idx, attempt in enumerate(range(10)):
    try:
        s = socket.socket()
        s.connect(("192.168.0.213", port))

        bdata = ""
        if downloadToFile:
            bdata += "DOWN "
        else:
            bdata += "EXEC "

        bdata += str(len(binfile)) + ":"

        if downloadToFile:
            bdata += outFilename

        bdata += "\n"

        bdata = bdata.encode()
        bdata = bdata + binfile
        s.send(bdata)
        rcv = s.recv(1024)

        if rcv != b'THX!':
            print("Got wrong response:")
            print(rcv)

        s.close()

    except Exception as e:
        s.close()
        #print(e)
        sleep(0.5)
    else:
        break

    if idx == 9:
        print("ERROR: could not send", outFilename)


if downloadToFile:
    print("File sent")
else:
    print("Program sent")