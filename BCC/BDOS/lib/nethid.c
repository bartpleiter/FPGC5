/*
* Network HID library
* Very simple network program that reads for HID codes
*  and forwards them to the HID fifo (after some parsing in case of an escape character)
*/

// uses wiz5500.c
// uses hidfifo.c

// Port for network bootloader
#define NETHID_PORT 3222
// Socket to listen to (0-7)
#define NETHID_SOCKET 7

word NETHID_isInitialized = 0;

// Buffer to read the RX buffer from W5500
char NETHID_rxBuf[WIZNET_MAX_RBUF];

// Handle session for socket s
// Data can contain multiple buffered inputs
void NETHID_handleSession(word s)
{
    // Size of received data
    // Double check to reduce error rate
    word rsize = 0;
    word rsizeValidate = 0;
    do {
        rsize = wizGetSockReg16(s, WIZNET_SnRX_RSR);
        if (rsize != 0)
        {
            // twice on purpose
            rsizeValidate = wizGetSockReg16(s, WIZNET_SnRX_RSR);
            rsizeValidate = wizGetSockReg16(s, WIZNET_SnRX_RSR);
        }
    } 
    while (rsize != rsizeValidate);

    if (rsize == 0)
    {
        // ignore, probably no data yet
        return;
    }

    // receive data
    wizReadRecvData(s, NETHID_rxBuf, rsize);
    NETHID_rxBuf[rsize] = 0; //terminate

    // echo data back to confirm receive
    wizWriteDataFromMemory(s, NETHID_rxBuf, rsize);

    // loop through the received data
    word isEscaped = 0;
    word ignoreThis = 0;
    word i;
    for (i = 0; i < rsize; i++)
    {
        if (ignoreThis)
        {
            ignoreThis--;
        }
        else
        {
            if (isEscaped)
            {
                isEscaped = 0;
                switch (NETHID_rxBuf[i])
                {
                case 65: // up
                    HID_FifoWrite(258);
                    break;
                case 66: // down
                    HID_FifoWrite(259);
                    break;
                case 67: // right
                    HID_FifoWrite(257);
                    break;
                case 68: // left
                    HID_FifoWrite(256);
                    break;
                }
            }
            else
            {
                // check for escape code
                if (NETHID_rxBuf[i] == 27)
                {
                    ignoreThis = 1; // skip the next one
                    isEscaped = 1;
                    // do real escape if this is the final character in buffer
                    //  since we do not expect anything quickly after an escape
                    if (i == rsize-1)
                    {
                        HID_FifoWrite(NETHID_rxBuf[i]);
                    }
                }
                else if (NETHID_rxBuf[i] == 127) // backspace
                {
                    HID_FifoWrite(8);
                }
                else // no parsing needed
                {
                    HID_FifoWrite(NETHID_rxBuf[i]);
                }
            }
        } 
    }
}


// Initialize netHID on socket s
void NETHID_init(word s)
{
    // Open socket in TCP Server mode
    wizInitSocketTCP(s, NETHID_PORT);

    NETHID_isInitialized = 1;
}


// Check for a change in the socket status
// Handles change if exists
void NETHID_loop(word s)
{
    // Get status for socket s
    word sxStatus = wizGetSockReg8(s, WIZNET_SnSR);

    if (sxStatus == WIZNET_SOCK_CLOSED)
    { 
        // Open the socket when closed
        wizInitSocketTCP(s, NETHID_PORT);
    }
    else if (sxStatus == WIZNET_SOCK_ESTABLISHED)
    {
        // Handle session when a connection is established
        NETHID_handleSession(s);
    }
    else if (sxStatus == WIZNET_SOCK_LISTEN)
    {
        // Keep on listening
    }
    else if (sxStatus == WIZNET_SOCK_SYNSENT || sxStatus == WIZNET_SOCK_SYNRECV || sxStatus == WIZNET_SOCK_FIN_WAIT || sxStatus == WIZNET_SOCK_TIME_WAIT)
    {
        // Do nothing in these cases
    }
    else
    {
        /*
        uprintln("Got unknown status:");
        uprintlnHex(sxStatus);
        */
        // In other cases, reset the socket
        wizInitSocketTCP(s, NETHID_PORT);
    }
    return;
}

