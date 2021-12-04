/*
* HID fifo library
* Contains fifo (circular buffer) for HID input codes
* Initially created for keyboard codes, but SNES controller codes could also be used
*   (although SNES is not supported anymore, an USB controller could also work for this)
*
* USAGE:
* - Use HID_FifoWrite in interrupt handler for input device
* - Check for key in main loop using HID_FifoAvailable
* - If available, read using HID_FifoRead
*/

#define HID_FIFO_SIZE 0x20

word hidfifo[HID_FIFO_SIZE];
word hidreadIdx = 0;
word hidwriteIdx = 0;
word hidbufSize = 0;


void HID_FifoWrite(word c)
{
    // We do not want to write null values
    if (c == 0)
        return;

    if (hidbufSize == HID_FIFO_SIZE)
    {
        uprintln("E: HID Buffer full");
        return;
    }

    word *p_hidfifo = hidfifo;
    *(p_hidfifo+hidwriteIdx) = c;

    hidbufSize++;   // Increase buffer size after writing
    hidwriteIdx++;  // Increase hidwriteIdx position to prepare for next write

    // If at last index in buffer, set hidwriteIdx back to 0
    if (hidwriteIdx == HID_FIFO_SIZE)
        hidwriteIdx = 0;
}

word HID_FifoAvailable()
{
    return (hidbufSize != 0);
}


word HID_FifoRead()
{
    // Check if buffer is empty
    if (hidbufSize == 0)
    {
        uprintln("E: HID Buffer empty");
        return 0;
    }

    word *p_hidfifo = hidfifo;
    word retval = *(hidfifo+hidreadIdx);

    hidbufSize--;   // Decrease buffer size after reading
    hidreadIdx++;   // Increase hidreadIdx position to prepare for next read

    // If at last index in buffer, set hidreadIdx back to 0
    if (hidreadIdx == HID_FIFO_SIZE)
        hidreadIdx = 0;

    return retval;
}
