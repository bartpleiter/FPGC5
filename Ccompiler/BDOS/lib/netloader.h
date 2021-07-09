/*
* Contains Network Bootloader
* Uses wiz5500 library
*/

#include "wiz5500.h"

// Port for network bootloader
#define NETLOADER_PORT 6969
// Socket to listen to (0-7)
#define NETLOADER_SOCKET 0

// States of network loader
#define NETLOADER_STATE_INIT 0
#define NETLOADER_STATE_DATA 1
#define NETLOADER_STATE_DONE 2
#define NETLOADER_STATE_USB 3
#define NETLOADER_STATE_USB_DATA 4

// State of network loader
int NETLOADER_transferState = NETLOADER_STATE_INIT;

// Checks if p starts with cmd
// Returns 1 if true, 0 otherwise
int NETLOADER_frameCompare(char* p, char* cmd)
{
    int i = 0;
    while (cmd[i] != 0)
    {
        if (cmd[i] != p[i])
        {
            return 0;
        }
        i += 1;
    }
    return 1;
}


int NETLOADER_wordPosition = 0;
int NETLOADER_currentByteShift = 24;

// Appends bytes from buffer to words in run address
void NETLOADER_appendBufferToRunAddress(char* b, int len)
{
    char* dst = (char*) RUN_ADDR;

    for (int i = 0; i < len; i++) 
    {
        char readByte = b[i];

        // Read 4 bytes into one word, from left to right
        readByte = readByte << NETLOADER_currentByteShift;
        dst[NETLOADER_wordPosition] = dst[NETLOADER_wordPosition] + readByte;


        if (NETLOADER_currentByteShift == 0)
        {
            NETLOADER_currentByteShift = 24;
            NETLOADER_wordPosition += 1;
            dst[NETLOADER_wordPosition] = 0;
        }
        else
        {
            NETLOADER_currentByteShift -= 8;
        }
    }
}


// Handle session for network loader on socket s
void NETLOADER_handleSession(int s)
{
    // Size of received data
    int rsize;
    rsize = wizGetSockReg16(s, SnRX_RSR);

    if (rsize == 0)
    {
        wizCmd(s, CR_DISCON);
        return;
    }

    // Receive frame
    char* rbuf = (char *) TEMP_ADDR;
    wizReadRecvData(s, rbuf, rsize);

    // Keep track if we received an unexpected frame
    int frameError = 0;

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

                // TODO: error handling

                char* p = (char *) FS_PATH_ADDR;
                // sanity check current path
                if (FS_sendFullPath(p) == ANSW_USB_INT_SUCCESS)
                {
                    int retval = FS_open();
                    // check that we can open the path
                    if (retval == ANSW_USB_INT_SUCCESS || retval == ANSW_ERR_OPEN_DIR)
                    {
                        // check length of filename
                        if (strlen(rbuf + 4) <= 12)
                        {
                            // uppercase filename
                            strToUpper(rbuf + 4);
                            // send filename
                            FS_sendSinglePath(rbuf + 4);

                            // create the file
                            if (FS_createFile() == ANSW_USB_INT_SUCCESS)
                            {
                                // open the path again
                                FS_sendFullPath(p);
                                FS_open();
                                // send filename again
                                FS_sendSinglePath(rbuf + 4);
                                // open the newly created file
                                if (FS_open() == ANSW_USB_INT_SUCCESS)
                                {
                                    // set cursor to start
                                    if (FS_setCursor(0) == ANSW_USB_INT_SUCCESS)
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
                frameError = 1;
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
            frameError = 1;
        }
    }

    // If we are downloading to file
    else if (NETLOADER_transferState == NETLOADER_STATE_USB_DATA)
    {
        // Check on data frame
        if (NETLOADER_frameCompare(rbuf, "DAT\n"))
        {
            // write buffer to opened file
            if (FS_writeFile(rbuf + 4, rsize - 4) != ANSW_USB_INT_SUCCESS)
            {
                frameError = 1;
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
            frameError = 1;
        }
    }
    else
    {
        frameError = 1;
    }


    // If we did not expect the frame we just received
    // Error report and go back to init state
    if (frameError != 0)
    {
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
void NETLOADER_init(int s)
{
    // Init W5500
    char ip_addr[4];
    ip_addr[0] = 192;
    ip_addr[1] = 168;
    ip_addr[2] = 0;
    ip_addr[3] = 213;

    char gateway_addr[4];
    gateway_addr[0] = 192;
    gateway_addr[1] = 168;
    gateway_addr[2] = 0;
    gateway_addr[3] = 1;

    char mac_addr[6];
    mac_addr[0] = 0xDE;
    mac_addr[1] = 0xAD;
    mac_addr[2] = 0xBE;
    mac_addr[3] = 0xEF;
    mac_addr[4] = 0x24;
    mac_addr[5] = 0x64;

    char sub_mask[4];
    sub_mask[0] = 255;
    sub_mask[1] = 255;
    sub_mask[2] = 255;
    sub_mask[3] = 0;

    wiz_Init(&ip_addr[0], &gateway_addr[0], &mac_addr[0], &sub_mask[0]);

    // Open socket in TCP Server mode
    wizInitSocketTCP(s, NETLOADER_PORT);
}


// Check for a change in the socket status
// Handles change if exists
void NETLOADER_loop(int s)
{
    // Get status for socket s
    int sxStatus = wizGetSockReg8(s, SnSR);

    if (sxStatus == SOCK_CLOSED)
    { 
        // Open the socket when closed
        wizInitSocketTCP(s, NETLOADER_PORT);
    }
    else if (sxStatus == SOCK_ESTABLISHED)
    {
        // Handle session when a connection is established
        NETLOADER_handleSession(s);
        delay(10);
    }
    else if (sxStatus == SOCK_LISTEN || sxStatus == SOCK_SYNSENT || sxStatus == SOCK_SYNRECV)
    {
        // Do nothing in these cases
        return;
    }
    else
    {
        // In other cases, reset the socket
        wizInitSocketTCP(s, NETLOADER_PORT);
    }
}


// Check if netloader is done so we can execute the received binary
// Returns 1 if executed program. Else 0
int NETLOADER_checkDone()
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
        UserprogramRunning = 1;

        // jump to the program
        ASM("\
        push r1 ;\
        push r2 ;\
        push r3 ;\
        push r4 ;\
        push r5 ;\
        push r6 ;\
        push r7 ;\
        push r8 ;\
        push r9 ;\
        push r10 ;\
        push r11 ;\
        push r12 ;\
        push r13 ;\
        push rbp ;\
        push rsp ;\
        savpc r1 ;\
        push r1 ;\
        jump 0x400000 ;\
        pop rsp ;\
        pop rbp ;\
        pop r13 ;\
        pop r12 ;\
        pop r11 ;\
        pop r10 ;\
        pop r9 ;\
        pop r8 ;\
        pop r7 ;\
        pop r6 ;\
        pop r5 ;\
        pop r4 ;\
        pop r3 ;\
        pop r2 ;\
        pop r1 ;\
        ");

        // Indicate that no user program is running anymore
        UserprogramRunning = 0;
        return 1;
    }

    return 0;
}