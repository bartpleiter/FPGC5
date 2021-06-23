/*
* Contains fifo (circular buffer) for HID input codes
* Initially created for keyboard codes, but SNES controller codes could also be used
*
* USAGE:
* - Use HID_FifoWrite in interrupt handler for input device
* - Check for key in main loop using HID_FifoAvailable
* - If available, read using HID_FifoRead
*/

#define HID_FIFO_SIZE 0x20

int hidfifo[HID_FIFO_SIZE] = 0;
int hidreadIdx = 0;
int hidwriteIdx = 0;
int hidbufSize = 0;


void HID_FifoWrite(int c)
{
    // We do not want to write null values
    if (c == 0)
        return;

    if (hidbufSize == HID_FIFO_SIZE)
    {
        uprintln("E: HID Buffer full");
        return;
    }

    int *p_hidfifo = hidfifo;
    *(p_hidfifo+hidwriteIdx) = c;

    hidbufSize += 1;  // Increase buffer size after writing
    hidwriteIdx += 1;    // Increase hidwriteIdx position to prepare for next write

    // If at last index in buffer, set hidwriteIdx back to 0
    if (hidwriteIdx == HID_FIFO_SIZE)
        hidwriteIdx = 0;
}

int HID_FifoAvailable()
{
    if (hidbufSize == 0)
        return 0;
    else
        return 1;
}


int HID_FifoRead()
{
    // Check if buffer is empty
    if (hidbufSize == 0)
    {
        uprintln("E: HID Buffer empty");
        return 0;
    }

    int *p_hidfifo = hidfifo;
    int retval = *(hidfifo+hidreadIdx);

    hidbufSize -= 1;  // Decrease buffer size after reading
    hidreadIdx += 1;     // Increase hidreadIdx position to prepare for next read

    // If at last index in buffer, set hidreadIdx back to 0
    if (hidreadIdx == HID_FIFO_SIZE)
        hidreadIdx = 0;

    return retval;
}
