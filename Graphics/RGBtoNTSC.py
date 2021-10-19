# Script to convert RGB332 to luma phase amplitude for NTSC composite

import colorsys
import numpy as np

# list of available phases using 5 bits
phaselist = []
for x in range(32):
    phaselist.append(x*11.25)

phaselist.append(360) # so we can set it back to 0 later if a match occurs


"""
         000 001 010  011  100  101  110  111
         -------------------------------------
r3bit    (0, 36, 73,  109, 146, 182, 219, 255)
g3bit    (0, 36, 73,  109, 146, 182, 219, 255)
b3bit    (0, 85, 170, 255)
         -----------------
         00  01  10   11
"""

def rgb2ypa(r3, g3, b2):
    r = r3/7.0
    g = g3/7.0
    b = b2/3.0
    y, i, q = colorsys.rgb_to_yiq(r, g, b)
    i = i #* 1.67813391509
    q = q #* 1.91241155097

    phase = 0.0
    if i != 0.0:
        phase = np.arctan2(q, i) # arctan2 to get full 360 degrees
        phase = np.degrees(phase) # radians to degrees
    
    # make phases positive
    if phase < 0.0:
        phase += 360.0

    f.append((phase))

    # match to closest available phase in phaselist, and get index
    phase = min(phaselist, key=lambda x:abs(x-phase))
    phase = phaselist.index(phase)
    if phase == 32:
        phase = 0

    # wrap around to match correct phase:
    """
    yellow-ish = ~1
    orange-ish = ~3
    red = 6
    purple/violet = 12
    blue = 18
    cyan = 22
    green = 29 (good sync point!)
    """
    phase = (phase + 5) % 32

    saturation = np.sqrt(i**2 + q**2)
    saturation = round(saturation*130) # multiply to fit range

    # add luma offset (72 = black)
    y = round(72 + y * (255-72))
    
    return y, phase, saturation




# loop through all 256 color possibilities
for i in range(256):

    b = 0
    if i&0b01:
        b += 1
    if i&0b10:
        b += 2

    g = 0
    if i&0b0100:
        g += 1
    if i&0b1000:
        g += 2
    if i&0b10000:
        g += 4

    r = 0
    if i&0b0100000:
        r += 1
    if i&0b1000000:
        r += 2
    if i&0b10000000:
        r += 4

    y, p, a = rgb2ypa(r, g, b)

    # create verilog code line for RGBtoYPhaseAmpl.v
    print("8'b" + format(i, '08b') + " : begin luma <= 8'd" + str(y) + "; phase <= 5'd" + str(p) + "; ampl <= 8'd" + str(a) + "; end")
