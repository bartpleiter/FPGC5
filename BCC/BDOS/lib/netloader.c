/*
* Network bootloader library
* Could be / is being extended to handle more network based commands
* Uses wiz5500 library
*/

// uses wiz5500.c

// Port for network bootloader
#define NETLOADER_PORT 3220
// Socket to listen to (0-7)
#define NETLOADER_SOCKET 0

// Checks if p starts with cmd
// Returns 1 if true, 0 otherwise
word NETLOADER_frameCompare(char* p, char* cmd)
{
    word i = 0;
    while (cmd[i] != 0)
    {
        if (cmd[i] != p[i])
        {
            return 0;
        }
        i++;
    }
    return 1;
}


word NETLOADER_wordPosition = 0;
word NETLOADER_currentByteShift = 24;

// Appends bytes from buffer to words in run address
void NETLOADER_appendBufferToRunAddress(char* b, word len)
{
    char* dst = (char*) RUN_ADDR;

    word i;
    for (i = 0; i < len; i++) 
    {
        char readByte = b[i];

        // Read 4 bytes into one word, from left to right
        readByte = readByte << NETLOADER_currentByteShift;
        dst[NETLOADER_wordPosition] = dst[NETLOADER_wordPosition] + readByte;


        if (NETLOADER_currentByteShift == 0)
        {
            NETLOADER_currentByteShift = 24;
            NETLOADER_wordPosition++;
            dst[NETLOADER_wordPosition] = 0;
        }
        else
        {
            NETLOADER_currentByteShift -= 8;
        }
    }
}

word NETLOADER_getContentLength(char* rbuf, word rsize)
{
    word contentLengthStr[32];
    word i = 5; // content length always at 5
    char c = rbuf[i];
    while (i < rsize && c != ':')
    {
        contentLengthStr[i-5] = c;
        i++;
        c = rbuf[i];
    }
    contentLengthStr[i-5] = 0; // terminate

    return strToInt(contentLengthStr);
}

void NETLOADER_getFileName(char* rbuf, word rsize, char* fileNameStr)
{
    word i = 0;
    
    char c = rbuf[i];
    while (i < rsize && c != ':')
    {
        i++;
        c = rbuf[i];
    }

    i++; // skip the :
    word x = 0;
    c = rbuf[i];
    while (i <rsize && c != '\n')
    {
        fileNameStr[x] = c;
        i++;
        x++;
        c = rbuf[i];
    }

    fileNameStr[x] = 0; // terminate
}

word NETLOADER_getContentStart(char* rbuf, word rsize)
{
    word i = 5; // content length always at 5
    char c = rbuf[i];
    while (i < rsize && c != '\n')
    {
        i++;
        c = rbuf[i];
    }

    return (i+1);
}

void NETLOADER_runProgramFromMemory()
{
    BDOS_Backup();

    // indicate that a user program is running
    BDOS_userprogramRunning = 1;

    // jump to the program
    asm(
        "; backup registers\n"
        "push r1\n"
        "push r2\n"
        "push r3\n"
        "push r4\n"
        "push r5\n"
        "push r6\n"
        "push r7\n"
        "push r8\n"
        "push r9\n"
        "push r10\n"
        "push r11\n"
        "push r12\n"
        "push r13\n"
        "push r14\n"
        "push r15\n"

        "savpc r1\n"
        "push r1\n"
        "jump 0x400000\n"

        "; restore registers\n"
        "pop r15\n"
        "pop r14\n"
        "pop r13\n"
        "pop r12\n"
        "pop r11\n"
        "pop r10\n"
        "pop r9\n"
        "pop r8\n"
        "pop r7\n"
        "pop r6\n"
        "pop r5\n"
        "pop r4\n"
        "pop r3\n"
        "pop r2\n"
        "pop r1\n"
        );

    // indicate that no user program is running anymore
    BDOS_userprogramRunning = 0;

    // clear the shell
    SHELL_clearCommand();

    // setup the shell again
    BDOS_Restore();
    SHELL_print_prompt();
}

word NETLOADER_percentageDone(word remaining, word full)
{
  word x = remaining * 100;
  return 100 - MATH_divU(x, full);
}

void NETLOADER_handleSession(word s)
{
    word firstResponse = 1;
    word contentLengthOrig = 0;
    word contentLength = 0;
    word currentProgress = 0;

    word downloadToFile = 0; // whether we need to download to a file instead
    char fileNameStr[32];

    char dbuf[10]; // percentage done for progress indication
    dbuf[0] = 0; // terminate

    while (wizGetSockReg8(s, WIZNET_SnSR) == WIZNET_SOCK_ESTABLISHED)
    {
        word rsize = wizGetSockReg16(s, WIZNET_SnRX_RSR);
        if (rsize != 0)
        {
            char* rbuf = (char *) TEMP_ADDR;
            wizReadRecvData(s, rbuf, rsize);
            if (firstResponse)
            {
                GFX_PrintConsole("\n");

                // save to and run from memory
                if (rbuf[0] == 'E' && rbuf[1] == 'X' && rbuf[2] == 'E' && rbuf[3] == 'C')
                {
                    GFX_PrintConsole("Receiving program\n");
                    downloadToFile = 0;

                    // reset position counters
                    NETLOADER_wordPosition = 0;
                    NETLOADER_currentByteShift = 24;

                    // clear first address of run addr
                    char* dst = (char*) RUN_ADDR;
                    dst[0] = 0;
                }
                // save to file
                else if (rbuf[0] == 'D' && rbuf[1] == 'O' && rbuf[2] == 'W' && rbuf[3] == 'N')
                {
                    GFX_PrintConsole("Receiving file\n");
                    downloadToFile = 1;

                    // get the filename
                    NETLOADER_getFileName(rbuf, rsize, fileNameStr);

                    word failedToCreateFile = 1;
                    // sanity check current path
                    if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
                    {
                        word retval = FS_open();
                        // check that we can open the path
                        if (retval == FS_ANSW_USB_INT_SUCCESS || retval == FS_ANSW_ERR_OPEN_DIR)
                        {
                            // check length of filename
                            if (strlen(fileNameStr) <= 12)
                            {
                                // uppercase filename
                                strToUpper(fileNameStr);
                                // send filename
                                FS_sendSinglePath(fileNameStr);

                                // create the file
                                if (FS_createFile() == FS_ANSW_USB_INT_SUCCESS)
                                {
                                    // open the path again
                                    FS_sendFullPath(SHELL_path);
                                    FS_open();
                                    // send filename again
                                    FS_sendSinglePath(fileNameStr);
                                    // open the newly created file
                                    if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
                                    {
                                        // set cursor to start
                                        if (FS_setCursor(0) == FS_ANSW_USB_INT_SUCCESS)
                                        {
                                            failedToCreateFile = 0;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (failedToCreateFile)
                    {
                        FS_close();
                        wizWriteDataFromMemory(s, "ERR!", 4);
                        wizCmd(s, WIZNET_CR_DISCON);
                        GFX_PrintConsole("E: Could not create file\n");
                        // clear the shell
                        SHELL_clearCommand();
                        SHELL_print_prompt();
                        return;
                    }
                }
                // unknown command
                else
                {
                    // unsupported command
                    wizWriteDataFromMemory(s, "ERR!", 4);
                    wizCmd(s, WIZNET_CR_DISCON);
                    GFX_PrintConsole("E: Unknown netloader cmd\n");
                    // clear the shell
                    SHELL_clearCommand();
                    SHELL_print_prompt();
                    return;
                }

                word dataStart = NETLOADER_getContentStart(rbuf, rsize);
                contentLength = NETLOADER_getContentLength(rbuf, rsize);
                contentLengthOrig = contentLength;

                contentLength -= (rsize - dataStart);

                if (downloadToFile)
                {
                    FS_writeFile(rbuf+dataStart, rsize - dataStart);
                }
                else
                {
                    NETLOADER_appendBufferToRunAddress(rbuf+dataStart, rsize - dataStart);
                }


                firstResponse = 0;

                // all data downloaded
                if (contentLength == 0)
                {
                    wizWriteDataFromMemory(s, "THX!", 4);
                    wizCmd(s, WIZNET_CR_DISCON);

                    if (downloadToFile)
                    {
                        FS_close();
                        // clear the shell
                        SHELL_clearCommand();
                        SHELL_print_prompt();
                    }
                    else
                    {
                        NETLOADER_runProgramFromMemory();
                    }
                    return;
                }
            }
            // not the first response
            else
            {

                // indicate progress
                // remove previous percentage
                word i = strlen(dbuf);
                while (i > 0)
                {
                    GFX_PrintcConsole(0x8); // backspace
                    i--;
                }
                if (strlen(dbuf) != 0)
                {
                    GFX_PrintcConsole(0x8); // backspace
                }

                itoa(NETLOADER_percentageDone(contentLength, contentLengthOrig), dbuf);
                GFX_PrintConsole(dbuf);
                GFX_PrintcConsole('%');


                contentLength -= rsize;

                if (downloadToFile)
                {
                    FS_writeFile(rbuf, rsize);
                }
                else
                {
                    NETLOADER_appendBufferToRunAddress(rbuf, rsize);
                }

                // all data downloaded
                if (contentLength == 0)
                {
                    wizWriteDataFromMemory(s, "THX!", 4);
                    wizCmd(s, WIZNET_CR_DISCON);

                    // remove progress prints
                    word i = strlen(dbuf);
                    while (i > 0)
                    {
                        GFX_PrintcConsole(0x8); // backspace
                        i--;
                    }
                    GFX_PrintcConsole(0x8); // backspace

                    if (downloadToFile)
                    {
                        FS_close();
                        // clear the shell
                        SHELL_clearCommand();
                        SHELL_print_prompt();
                    }
                    else
                    {
                        NETLOADER_runProgramFromMemory();
                    }
                    return;
                }
            }
        }
    }
}


// Initialize network bootloader on socket s
void NETLOADER_init(word s)
{
    // Open socket in TCP Server mode
    wizInitSocketTCP(s, NETLOADER_PORT);
}


// Check for a change in the socket status
// Handles change if exists
word NETLOADER_loop(word s)
{
    // Get status for socket s
    word sxStatus = wizGetSockReg8(s, WIZNET_SnSR);

    if (sxStatus == WIZNET_SOCK_CLOSED)
    { 
        // Open the socket when closed
        wizInitSocketTCP(s, NETLOADER_PORT);
    }
    else if (sxStatus == WIZNET_SOCK_ESTABLISHED)
    {
        // Handle session when a connection is established
        NETLOADER_handleSession(s);
    }
    else if (sxStatus == WIZNET_SOCK_LISTEN)
    {
        // Keep on listening
        return 1;
    }
    else if (sxStatus == WIZNET_SOCK_SYNSENT || sxStatus == WIZNET_SOCK_SYNRECV || sxStatus == WIZNET_SOCK_FIN_WAIT || sxStatus == WIZNET_SOCK_TIME_WAIT)
    {
        // Do nothing in these cases
        return 2;
    }
    else
    {
        // In other cases, reset the socket
        wizInitSocketTCP(s, NETLOADER_PORT);
    }

    return 0;
}

