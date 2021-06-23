from PIL import Image


def rgb_to_hsl(r, g, b):
    r = float(r)
    g = float(g)
    b = float(b)
    high = max(r, g, b)
    low = min(r, g, b)
    h, s, v = ((high + low) / 2,)*3

    return v

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
    lumlist = []

    for a in range(8):
        for b in range(8):
            if tile[a][b] not in colorList:
                colorList.append(tile[a][b])

    if len(colorList) > 4:
        print("tile ", idx, " has more than 4 colors")

    #order color list from dark to light
    colorList.sort(key=lambda x: rgb_to_hsl(x[0], x[1], x[2]) )

    print(".dw 0b", end = '')
    for a in range(8):
        for b in range(8):
            if colorList.index(tile[a][b]) == 0:
                print("00", end = '')
            if colorList.index(tile[a][b]) == 1:
                print("01", end = '')
            if colorList.index(tile[a][b]) == 2:
                print("10", end = '')
            if colorList.index(tile[a][b]) == 3:
                print("11", end = '')
        if (a+1) % 2 == 0 and a != 7:
            print()
            print(".dw 0b", end = '')

    print(" ; tile ", idx)


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
