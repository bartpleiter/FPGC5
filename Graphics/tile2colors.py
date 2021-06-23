from PIL import Image
from math import sqrt


def rgb_to_hsl(r, g, b):
    r = float(r)
    g = float(g)
    b = float(b)
    high = max(r, g, b)
    low = min(r, g, b)
    h, s, v = ((high + low) / 2,)*3

    return v

def createPalette(color):
    if color[3] == 0:
        return "00000000"
    else:
        R3 = int(round(color[0] * 7 / 255))
        G3 = int(round(color[1] * 7 / 255))
        B2 = int(round( (color[2]-148)**3 * (1*9**(-6)) + 1.4 ))  #color[2] * 3 / 255
        if B2 < 0:
            B2 = 0
        if B2 > 3:
            B2 = 3
        colorString = format(R3, '03b') + format(G3, '03b') + format(B2, '02b')
        
        return colorString

#img: image to process
#x: starting x position
#y: starting y position
#idx: index of pattern table, corresponding to index of tiles
def createPattern(img, x, y, idx):
    tile = []
    for a in range(8):
        tileLine = []
        for b in range(8):
            pixel = px[x*8+b, y*8+a]
            tileLine.append(pixel)
        tile.append(tileLine)

    colorList = []

    for a in range(8):
        for b in range(8):
            if tile[a][b] not in colorList:
                colorList.append(tile[a][b])

    #order color list from dark to light
    colorList.sort(key=lambda x: rgb_to_hsl(x[0], x[1], x[2]) )

    if len(colorList) > 4:
        print("tile ", idx, " has more than 4 colors")

    paletteList = []

    for i in range(4):
        if i < len(colorList):
            paletteList.append(createPalette(colorList[i]))

    paletteString = "".join(paletteList)

    paletteString = paletteString.ljust(32, "0") + " ;" + str(idx)

    #swap second and third color intentionally
    swappedPaletteString = paletteString[0:8] + paletteString[16:24] + paletteString[8:16] + paletteString[24:]

    print(swappedPaletteString)




    


im = Image.open('tiles.png')
width, height = im.size
px = im.load()

#print(px[0,0])
print("Width:", width, "px")
print("Height:", height, "px")

if (width%8 != 0):
    print("Width not dividable by 8")
    exit(1)

if (height%8 != 0):
    print("Height not dividable by 8")
    exit(1)

htiles = int(width / 8)
vtiles = int(height / 8)
tiles = htiles * vtiles

print("Horizontal tiles:", htiles)
print("Vertical tiles:", vtiles)
print("Total number of tiles:", tiles)

print("Index of tiles:")
tile_i = 0
for y in range(vtiles):
    for x in range(htiles):
        print (str(tile_i) + "\t", end = '')
        tile_i = tile_i + 1
        #function: create pattern of tile
    print()

print()
print()

tile_i = 0
for y in range(vtiles):
    for x in range(htiles):
        createPattern(px, x, y, tile_i)
        tile_i = tile_i + 1
        
#createPattern(px, 0, 0, 0)
