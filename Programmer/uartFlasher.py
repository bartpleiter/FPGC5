#!/usr/bin/env python3

# WSL1 version. Deamon thread stops automatically when program stops
# I do not expect this to happen on "real" linux

import serial
from time import sleep
import sys
import fileinput
import threading

stop_threads = False

def writeThread(port):
    global stop_threads 

    try:
        for line in fileinput.input():
            if stop_threads: 
                exit()
            for c in line:
                port.write(c.encode('utf-8'))
                sleep(0.0001) # give the FPGC time to process the UART in software

    except:
        exit()
        

testReturnMode = False  # mode where we do not use a serial monitor,
                        # but instead wait for one byte and use it as return code of this program
if len(sys.argv) > 1:
    if (sys.argv[1] == "testMode"):
        testReturnMode = True

port = serial.Serial("/dev/ttyUSB0", baudrate=115200, timeout=None)

sleep(0.3) # give the FPGC time to reset, even though it also works without this delay

# parse byte file
ba = bytearray()

with open("code.bin", "rb") as f:
    bytes_read = f.read()
for b in bytes_read:
    ba.append(b)

# combine each 4 bytes into a word
n = 4
wordList = [ba[i * n:(i + 1) * n] for i in range((len(ba) + n - 1) // n )]  

# size of program is in address 5
fileSize = bytes(wordList[5])

print(int.from_bytes(fileSize, "big"), flush=True)

# write filesize
port.write(fileSize)

# read four bytes
rcv = port.read(4)

# to verify if communication works
print(rcv, flush=True)


# send all words
doneSending = False

wordCounter = 0

while not doneSending:
    port.write(bytes(wordList[wordCounter]))
    wordCounter = wordCounter + 1

    if (wordCounter == int.from_bytes(fileSize, "big")):
        doneSending = True

print("Done programming", flush=True)
port.read(1) # should return 'd', though I'm not checking on it

if testReturnMode:
    rcv = port.read(1)
    retval = int.from_bytes(rcv, "little")
    print("FPGC4 returned: ", retval)
    sys.exit(retval)

else:
    print("\nSerial monitor:", flush=True)

    t1 = threading.Thread(target = writeThread, args=[port])
    t1.daemon = True
    t1.start()

    try:
        while True:
            bytesToRead = port.in_waiting
            if(bytesToRead > 0):
                rcv = port.read(1)
                try:
                    print(rcv.decode("utf-8"), end = '', flush=True)
                except:
                    print(rcv, end = '', flush=True)
            else:
                sleep(.01) # allow CPU to idle
    except KeyboardInterrupt:
        print("\nClosing Serial Monitor")
        stop_threads = True
        # t1.join()