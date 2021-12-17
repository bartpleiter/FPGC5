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

for attempt in range(10):
    if attempt != 0:
        sleep(1)

    # init connection
    s = socket.socket()
    port = 3220

    try:
        s.connect(("192.168.0.213", port))
    

        # notify new file
        bdata = b"NEW\n"
        s.send(bdata)
        rcv = s.recv(1024)

        if rcv != b'DONE':
            print("Got wrong response:")
            print(rcv)
            continue

        print("Sending file")

        # send data of file in chunks
        chunk_size = 1024
        for i in range(0, len(binfile), chunk_size):
            chunk = b"DAT\n"
            chunk += binfile[i:i+chunk_size]
            s.send(chunk)
            print(".", end='', flush=True)
            rcv = s.recv(1024) # wait until processed
            if rcv != b'DONE':
                print("Got wrong response:")
                print(rcv)
                s.close()
                continue

        print() # print new line

        # notify done
        bdata = b"END\n"
        s.send(bdata)
        rcv = s.recv(1024)

        if rcv != b'DONE':
            print("Got wrong response:")
            print(rcv)
            s.close()
            continue

    except:
        print("Could not connect")
        continue

    print("File sent")

    # close socket when done
    s.close()

    exit(0)