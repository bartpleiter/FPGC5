#!/usr/bin/env python3

# Sends user program to BDOS over network.
# Program is directly written to memory.
# Current transfer+processing speed: ~11KB/s
# NOTE: DO NOT USE WIFI!!! use a stable ethernet connection instead

import socket
import sys

# read file to send
filename = "code.bin" #default filename to send
if len(sys.argv) >= 2:
    filename = sys.argv[1]

with open(filename, "rb") as f:
    binfile = f.read()

# init connection
s = socket.socket()
port = 6969
s.connect(("192.168.0.213", port))

# notify new file
bdata = b"NEW\n"
s.send(bdata)
rcv = s.recv(1024)

if rcv != b'DONE':
    print("Got wrong response:")
    print(rcv)
    exit()

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
        exit()

print() # print new line

# notify done
bdata = b"END\n"
s.send(bdata)
rcv = s.recv(1024)

if rcv != b'DONE':
    print("Got wrong response:")
    print(rcv)
    s.close()
    exit()

print("File sent")

# close socket when done
s.close()