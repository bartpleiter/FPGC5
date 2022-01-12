#!/bin/bash

# script to sync all C files in UserBDOS/ to /C/SRC/ on FPGC
# assumes the subdirectories already exist. In theory a mkdir command could be added
#  (mkdir does nothing if the directory already exists)

MAINPATH=$(pwd)

echo $MAINPATH

cd userBDOS

echo "clear" | python3 "$MAINPATH/../Programmer/sendCommand.py"
echo "cd" | python3 "$MAINPATH/../Programmer/sendCommand.py"
echo "clear" | python3 "$MAINPATH/../Programmer/sendCommand.py"

for i in $(find . -type f -print)
do
    FNAME=$(basename $i)
    DIR=$(dirname $i | cut -c 2-)

    echo "sending $DIR/$FNAME"
    # move to directory
    echo "cd /C/SRC$DIR" | python3 "$MAINPATH/../Programmer/sendCommand.py"
    # send file
    python3 "$MAINPATH/../Programmer/netUpload.py" "$i" "$FNAME"

done