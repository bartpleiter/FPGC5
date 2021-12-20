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

// States of network loader
#define NETLOADER_STATE_INIT 0
#define NETLOADER_STATE_DATA 1
#define NETLOADER_STATE_DONE 2
#define NETLOADER_STATE_USB 3
#define NETLOADER_STATE_USB_DATA 4

// State of network loader
word NETLOADER_transferState = NETLOADER_STATE_INIT;

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


// Handle session for network loader on socket s
void NETLOADER_handleSession(word s)
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

    // Receive frame
    char* rbuf = (char *) TEMP_ADDR;
    wizReadRecvData(s, rbuf, rsize);
    rbuf[rsize] = 0; //terminate

    // Keep track if we received an unexpected frame
    word frameError = 0;

    // If no file transfer has started yet, check for "NEW" frame, or "USB" frame
    if (NETLOADER_transferState == NETLOADER_STATE_INIT)
    {
        // Check on initialisation frame
        if (NETLOADER_frameCompare(rbuf, "NEW\n"))
        {
            NETLOADER_transferState = NETLOADER_STATE_DATA; // set state to receive data

            // Reset position counters
            NETLOADER_wordPosition = 0;
            NETLOADER_currentByteShift = 24;

            // Clear first address of run addr
            char* dst = (char*) RUN_ADDR;
            dst[0] = 0;
        }
        else
        {
            if (NETLOADER_frameCompare(rbuf, "USB\n"))
            {
                NETLOADER_transferState = NETLOADER_STATE_USB_DATA; // set state

                frameError = 1;

                // TODO: error handling for all if cases

                // sanity check current path
                if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
                {
                    word retval = FS_open();
                    // check that we can open the path
                    if (retval == FS_ANSW_USB_INT_SUCCESS || retval == FS_ANSW_ERR_OPEN_DIR)
                    {
                        // check length of filename
                        if (strlen(rbuf + 4) <= 12)
                        {
                            // uppercase filename
                            strToUpper(rbuf + 4);
                            // send filename
                            FS_sendSinglePath(rbuf + 4);

                            // create the file
                            if (FS_createFile() == FS_ANSW_USB_INT_SUCCESS)
                            {
                                // open the path again
                                FS_sendFullPath(SHELL_path);
                                FS_open();
                                // send filename again
                                FS_sendSinglePath(rbuf + 4);
                                // open the newly created file
                                if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
                                {
                                    // set cursor to start
                                    if (FS_setCursor(0) == FS_ANSW_USB_INT_SUCCESS)
                                    {
                                        frameError = 0;
                                    }
                                }
                            }
                        }
                    }
                }

                
            }
            else
            {
                frameError = 2;
            }
        }
    }
    // If we are in a data receiver state
    else if (NETLOADER_transferState == NETLOADER_STATE_DATA)
    {
        // Check on data frame
        if (NETLOADER_frameCompare(rbuf, "DAT\n"))
        {
            // Copy data after "DAT\n" to RUN_ADDR
            NETLOADER_appendBufferToRunAddress(rbuf + 4, rsize - 4);
        }
        // Check on finish frame
        else if (NETLOADER_frameCompare(rbuf, "END\n"))
        {
            // Note length of file
            //NETLOADER_dataLen = NETLOADER_dataCursor;

            // Terminate file
            //char* dst = (char*) RUN_ADDR;
            //*(dst + NETLOADER_dataLen) = 0;
            
            // Set state to done
            NETLOADER_transferState = NETLOADER_STATE_DONE;
        }
        else
        {
            frameError = 3;
        }
    }

    // If we are downloading to file
    else if (NETLOADER_transferState == NETLOADER_STATE_USB_DATA)
    {
        // Check on data frame
        if (NETLOADER_frameCompare(rbuf, "DAT\n"))
        {
            // write buffer to opened file
            if (FS_writeFile(rbuf + 4, rsize - 4) != FS_ANSW_USB_INT_SUCCESS)
            {
                frameError = 4;
            }
        }
        // Check on finish frame
        else if (NETLOADER_frameCompare(rbuf, "END\n"))
        {
            // close file, no need to check for errors
            FS_close();
            
            // Set state to init, since no action is needed
            NETLOADER_transferState = NETLOADER_STATE_INIT;
        }
        else
        {
            frameError = 5;
        }
    }
    else
    {
        frameError = 6;
    }


    // If we did not expect the frame we just received
    // Error report and go back to init state
    if (frameError != 0)
    {
        /* useful for debugging the error
        uprint("frameError: ");
        uprintlnDec(frameError);

        uprint("rsize: ");
        uprintlnDec(rsize);

        uprint("rbuf: ");
        uprintln(rbuf);
        */

        // notify error
        char* retTxt = "ERROR";
        wizWriteDataFromMemory(s, retTxt, 5);
        NETLOADER_transferState = NETLOADER_STATE_INIT;
    }
    else
    {
        // notify success
        char* retTxt = "DONE";
        wizWriteDataFromMemory(s, retTxt, 4);
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
        //delay(10);
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
        /*
        uprintln("Got unknown status:");
        uprintlnHex(sxStatus);
        */
        // In other cases, reset the socket
        wizInitSocketTCP(s, NETLOADER_PORT);
    }

    return 0;
}


// Check if netloader is done so we can execute the received binary
// Returns 1 if executed program. Else 0
word NETLOADER_checkDone()
{
    // Check if we successfully received a file
    if (NETLOADER_transferState == NETLOADER_STATE_DONE)
    {
        // Go back to init state (only useful for debug print instead of running the file)
        NETLOADER_transferState = NETLOADER_STATE_INIT;
        // Print file
        //char* p = (char*) RUN_ADDR;
        //GFX_PrintConsole(p);

        BDOS_Backup();

        // Indicate that a user program is running
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

        // Indicate that no user program is running anymore
        BDOS_userprogramRunning = 0;

        // Clear the shell
        SHELL_clearCommand();
        
        return 1;
    }

    return 0;
}