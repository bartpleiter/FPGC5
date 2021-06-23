#!/usr/bin/env python3

import mido
import sys

mid = mido.MidiFile(sys.argv[1])

msgList = []

for msg in mid:
    if msg.type == 'note_on' or msg.type == 'note_off':
        msgList.append(msg)


print("MUSICNOTES:")
print("; midi data")
print(".dw ", end = '')
for idx, x in enumerate(msgList):
    if (idx%20 == 19):
        print("\n.dw ", end = '')

    print(x.bytes()[0], end = ' ')
    print(x.bytes()[1], end = ' ')
    velocity = x.bytes()[2]
    if velocity > 80:
        velocity = 80
    print(velocity, end = ' ')

print("\n")

print("MUSICLENS:")
print("; delaytimes")
print(".dw ", end = '')
for idx, x in enumerate(msgList):
    if (idx%20 == 19):
        print("\n.dw ", end = '')
    intLen = int(x.time*1000)
    if (intLen) == 0:
        intLen = 1
    print(intLen, end = ' ')

print()
