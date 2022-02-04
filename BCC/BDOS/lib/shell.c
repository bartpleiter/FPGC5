/*
* Shell library
* Contains shell functions
*/

// uses fs.c
// uses hidfifo.c
// uses gfx.c
// uses stdlib.c

// Max length of a single command
#define SHELL_CMD_MAX_LENGTH 128

// The number of commands to remember
#define SHELL_CMD_HISTORY_LENGTH 32

// Address of user program (already defined in BDOS.c)
//#define RUN_ADDR 0x400000

// Chunk size for reading files and programs
// NOTE: must be dividable by 4
#define SHELL_FILE_READ_CHUNK_SIZE 512
#define SHELL_PROGRAM_READ_CHUNK_SIZE 32768

// The current command that is being typed
char SHELL_command[SHELL_CMD_MAX_LENGTH];
word SHELL_commandIdx = 0; // index in current command

word SHELL_promptCursorPos = 0;

// History of commands
char SHELL_history[SHELL_CMD_HISTORY_LENGTH][SHELL_CMD_MAX_LENGTH];
word SHELL_historyPtr = 0; // index of next entry in history
word SHELL_historySelectIdx = 0; // index of selected entry in history
word SHELL_historyMovedBackwards = 0; // number of times that the user moved backwards in history
word SHELL_historyLength = 0; // number of filled entries in history


// Appends current CMD to history, ignores empty commands
void SHELL_historyAppend()
{
    // ignore empty command
    if (SHELL_command[0] == 0)
    {
        return;
    }

    // wrap around if full, overwriting the oldest entries
    if (SHELL_historyPtr == SHELL_CMD_HISTORY_LENGTH)
    {
        SHELL_historyPtr = 0;
    }

    strcpy(SHELL_history[SHELL_historyPtr], SHELL_command);

    SHELL_historyPtr++;
    // sync currently selected with the latest command
    SHELL_historySelectIdx = SHELL_historyPtr;

    // no need to update length if the history is already full
    if (SHELL_historyLength < SHELL_CMD_HISTORY_LENGTH)
    {
        SHELL_historyLength++;
    }
}

void SHELL_historyGoBack()
{
    // ignore if we have gone fully back in time
    if (SHELL_historyMovedBackwards < SHELL_historyLength)
    {
        SHELL_historyMovedBackwards++;

        // go back in history, wrap around select idx
        if (SHELL_historySelectIdx == 0)
        {
            SHELL_historySelectIdx = SHELL_CMD_HISTORY_LENGTH;
        }
        else
        {
            SHELL_historySelectIdx--;
        }
        SHELL_setCommand(SHELL_history[SHELL_historySelectIdx]);
    }
}

void SHELL_historyGoForwards()
{
    // only if we are in the past
    if (SHELL_historyMovedBackwards > 0)
    {
        SHELL_historyMovedBackwards--;

        // go forward in history, wrap around select idx
        if (SHELL_historySelectIdx == SHELL_CMD_HISTORY_LENGTH)
        {
            SHELL_historySelectIdx = 0;
        }
        else
        {
            SHELL_historySelectIdx++;
        }
        SHELL_setCommand(SHELL_history[SHELL_historySelectIdx]);

        // clear command if back in present
        if (SHELL_historyMovedBackwards == 0)
        {
            // use backspaces to clear the text on screen
            while (SHELL_commandIdx > 0)
            {
                GFX_PrintcConsole(0x8);
                SHELL_commandIdx--;
            }
            SHELL_clearCommand();
        }
    }
}

// Clears the current command in memory
void SHELL_clearCommand()
{
    SHELL_command[0] = 0;
    SHELL_commandIdx = 0;
}

// Clears current command and replaces it with cmd
void SHELL_setCommand(char* cmd)
{
    if (cmd[0] == 0)
    {
        return;
    }

    // clear current command on screen by doing backspaces
    while (SHELL_commandIdx > 0)
    {
        GFX_PrintcConsole(0x8);
        SHELL_commandIdx--;
    }

    strcpy(SHELL_command, cmd);

    // set new shell cmd index
    SHELL_commandIdx = strlen(SHELL_command);

    // print new command
    GFX_PrintConsole(SHELL_command);
}

// Prints current display prompt
void SHELL_print_prompt()
{
    // TODO: if path > X chars, only show last X-1 chars with some character in front
    GFX_PrintConsole(SHELL_path);
    GFX_PrintConsole("> ");
    SHELL_promptCursorPos = GFX_cursor;
}


// Initialize shell
void SHELL_init()
{
    // clear current command
    SHELL_clearCommand();

    // clear screen
    GFX_clearWindowtileTable();
    GFX_clearWindowpaletteTable();
    GFX_cursor = 0;

    SHELL_print_prompt();
}


// Checks if p starts with cmd, followed by a space or a \0
// Returns 1 if true, 0 otherwise
word SHELL_commandCompare(char* p, char* cmd)
{
    word similar = 1;

    word i = 0;
    while (cmd[i] != 0)
    {
        if (cmd[i] != p[i])
        {
            similar = 0;
        }
        i += 1;
    }

    if (similar)
    {
        similar = 0;
        if (p[i] == 0 || p[i] == ' ')
            similar = 1;
    }

    return similar;
}


// Returns the number of arguments of a command line
// Does this by counting the number times a character is placed
//  directly after a space
word SHELL_numberOfArguments(char* p)
{
    word args = 0;

    word foundSpace = 0;
    word i = 0;
    while (p[i] != 0)
    {
        if (p[i] == ' ')
        {
            foundSpace = 1;
        }
        else
        {
            if (foundSpace)
            {
                // if character after space
                if (p[i] != 0)
                {
                    args += 1;
                }
                foundSpace = 0;
            }
        }
        i += 1;
    }

    return args;
}


// Implementation of ldir command
// Lists directory given in arg
// Argument is passed in arg and should end with a \0 (not space)
void SHELL_ldir(char* arg)
{
    // backup current path
    strcpy(SHELL_pathBackup, SHELL_path);

    // add arg to path
    if (FS_changePath(arg) == FS_ANSW_USB_INT_SUCCESS)
    {
        // do listdir
        char *b = (char *) TEMP_ADDR;
        if (FS_listDir(SHELL_path, b) == FS_ANSW_USB_INT_SUCCESS)
        {
            GFX_PrintConsole(b);
        }

        // restore path
        strcpy(SHELL_path, SHELL_pathBackup);
    }
    else
    {
        GFX_PrintConsole("E: Invalid path\n");
    }
}


// Implementation of run command
// Loads file to memory at RUN_ADDR and jumps to it
// Argument is passed in arg and should end with a \0 or space
// If useBin is set, it will look for the file in the /BIN folder
void SHELL_runFile(char* arg, word useBin)
{
    // backup current path
    strcpy(SHELL_pathBackup, SHELL_path);

    // replace space with \0
    word i = 0;
    word putBackSpaceIndex = 0; // and put back later for args
    while(*(arg+i) != ' ' && *(arg+i) != 0)
    {
        i++;
    }
    if (*(arg+i) == ' ')
    {
        putBackSpaceIndex = i;
    }
    *(arg+i) = 0;

    if (useBin)
    {
        strcpy(SHELL_path, "/BIN/");
        strcat(SHELL_path, arg);
    }
    else
    {
        // create full path using arg
        FS_getFullPath(arg);
    }

    // if the resulting path is correct (can be file or directory)
    if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
    {

        // if we can successfully open the file (not directory)
        if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
        {
            word fileSize = FS_getFileSize();

            if ((unsigned int) fileSize <= (unsigned int) 0x300000)
            {
                if (FS_setCursor(0) == FS_ANSW_USB_INT_SUCCESS)
                {
                    // read the file in chunks
                    char *b = (char *) RUN_ADDR;  

                    word bytesSent = 0;

                    GFX_PrintConsole("Loading");

                    word loopCount = 0; // counter for animation

                    // loop until all bytes are sent
                    while (bytesSent != fileSize)
                    {
                        word partToSend = fileSize - bytesSent;
                        // send in parts of SHELL_PROGRAM_READ_CHUNK_SIZE
                        if ((unsigned int) partToSend > (unsigned int) SHELL_PROGRAM_READ_CHUNK_SIZE)
                        partToSend = SHELL_PROGRAM_READ_CHUNK_SIZE;

                        // read from usb to memory in word mode
                        if (FS_readFile(b, partToSend, 1) != FS_ANSW_USB_INT_SUCCESS)
                            uprintln("W: Error reading file\n");

                        // indicate progress
                        if (loopCount == 3)
                        {
                            GFX_PrintcConsole(0x8); // backspace
                            GFX_PrintcConsole(0x8); // backspace
                            GFX_PrintcConsole(0x8); // backspace
                            loopCount = 0;
                        }
                        else
                        {
                            GFX_PrintcConsole('.');
                            loopCount++;
                        }

                        // Update the amount of bytes sent
                        bytesSent += partToSend;
                        b += (partToSend>>2); // divide by 4 because one address is 4 bytes
                    }

                    // remove the dots
                    for (loopCount; loopCount > 0; loopCount--)
                    {
                        GFX_PrintcConsole(0x8); // backspace
                    }

                    // close file after done
                    FS_close();

                    // remove the loading text
                    word i;
                    for (i = 0; i < 7; i++)
                    {
                        GFX_PrintcConsole(0x8); // backspace
                    }

                    // put back the space in the command
                    if (putBackSpaceIndex != 0)
                    {
                        *(arg+putBackSpaceIndex) = ' ';
                    }

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

                    BDOS_Restore();
                
                }
                else
                    GFX_PrintConsole("E: Could not move to start of file\n");
            }
            else
                GFX_PrintConsole("E: Program is too large\n");
        }
        else
        {
            if (useBin)
                GFX_PrintConsole("E: Unknown command\n");
            else
                GFX_PrintConsole("E: Could not open file\n");
        }
    }
    else
    {
        if (useBin)
            GFX_PrintConsole("E: Unknown command\n");
        else
            GFX_PrintConsole("E: Invalid path\n");
    }

    // restore path
    strcpy(SHELL_path, SHELL_pathBackup);
}


// Implementation of print command
// Prints file to screen
// Argument is passed in arg and should end with a \0 (not space)
void SHELL_printFile(char* arg)
{
    // backup current path
    strcpy(SHELL_pathBackup, SHELL_path);

    // create full path using arg
    FS_getFullPath(arg);

    // if the resulting path is correct (can be file or directory)
    if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
    {

        // if we can successfully open the file (not directory)
        if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
        {
            word fileSize = FS_getFileSize();

            if (FS_setCursor(0) == FS_ANSW_USB_INT_SUCCESS)
            {
                // read the file in chunks
                char *b = (char *) TEMP_ADDR;  

                word bytesSent = 0;

                // loop until all bytes are sent
                while (bytesSent != fileSize)
                {
                    word partToSend = fileSize - bytesSent;
                    // send in parts of SHELL_FILE_READ_CHUNK_SIZE
                    if ((unsigned int) partToSend > (unsigned int) SHELL_FILE_READ_CHUNK_SIZE)
                    partToSend = SHELL_FILE_READ_CHUNK_SIZE;

                    // read from usb to buffer in byte mode
                    if (FS_readFile(b, partToSend, 0) != FS_ANSW_USB_INT_SUCCESS)
                        uprintln("W: Error reading file\n");

                    // append buffer with terminator
                    *(b+partToSend) = 0;

                    // print buffer to console
                    GFX_PrintConsole(b);

                    // Update the amount of bytes sent
                    bytesSent += partToSend;
                }

                // close file after done
                FS_close();

                // end with a newline for the next shell prompt
                GFX_PrintcConsole('\n');
            }
            else
                GFX_PrintConsole("E: Could not move to start of file\n");
        }
        else
            GFX_PrintConsole("E: Could not open file\n");
    }
    else
        GFX_PrintConsole("E: Invalid path\n");

    // restore path
    strcpy(SHELL_path, SHELL_pathBackup);
}


// Removes file/dir
void SHELL_remove(char* arg)
{
    // backup current path
    strcpy(SHELL_pathBackup, SHELL_path);

    // create full path using arg
    FS_getFullPath(arg);

    // if the resulting path is correct (can be file or directory)
    if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
    {

        // if we can successfully open the file (not directory)
        word retval = FS_open();
        if (retval == FS_ANSW_USB_INT_SUCCESS)
        {
            if (FS_delete() == FS_ANSW_USB_INT_SUCCESS)
            {
                GFX_PrintConsole("File removed\n");
            }
            else
                GFX_PrintConsole("E: Could not delete file\n");
        }
        else if (retval == FS_ANSW_ERR_OPEN_DIR)
        {
            if (FS_delete() == FS_ANSW_USB_INT_SUCCESS)
            {
                GFX_PrintConsole("Dir removed\n");
            }
            else
                GFX_PrintConsole("E: Could not delete dir\n");
        }
        else
            GFX_PrintConsole("E: Could not find file or dir\n");
    }
    else
        GFX_PrintConsole("E: Invalid path\n");

    // restore path
    strcpy(SHELL_path, SHELL_pathBackup);
}


// Creates file in current directory
void SHELL_createFile(char* arg)
{
    // backup current path
    strcpy(SHELL_pathBackup, SHELL_path);

    // if current path is correct (can be file or directory)
    if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
    {
        word retval = FS_open();
        // check that we can open the path
        if (retval == FS_ANSW_USB_INT_SUCCESS || retval == FS_ANSW_ERR_OPEN_DIR)
        {
            // check length of filename
            if (strlen(arg) <= 12)
            {
                // uppercase filename
                strToUpper(arg);
                // send filename
                FS_sendSinglePath(arg);

                // create the file
                if (FS_createFile() == FS_ANSW_USB_INT_SUCCESS)
                {
                    GFX_PrintConsole("File created\n");
                }
                else
                    GFX_PrintConsole("E: Could not create file\n");
            }
            else
                GFX_PrintConsole("E: Filename too long\n");
        }
        else
            GFX_PrintConsole("E: Invalid path\n");
    }
    else
        GFX_PrintConsole("E: Invalid path\n");

    // restore path
    strcpy(SHELL_path, SHELL_pathBackup);
}


// Creates directory in current directory
void SHELL_createDir(char* arg)
{
    // backup current path
    strcpy(SHELL_pathBackup, SHELL_path);

    // if current path is correct (can be file or directory)
    if (FS_sendFullPath(SHELL_path) == FS_ANSW_USB_INT_SUCCESS)
    {
        word retval = FS_open();
        // check that we can open the path
        if (retval == FS_ANSW_USB_INT_SUCCESS || retval == FS_ANSW_ERR_OPEN_DIR)
        {
            // check length of directory, must be 8
            if (strlen(arg) <= 8)
            {
                // uppercase filename
                strToUpper(arg);
                // send filename
                FS_sendSinglePath(arg);

                // create the directory
                if (FS_createDir() == FS_ANSW_USB_INT_SUCCESS)
                {
                    GFX_PrintConsole("Dir created\n");
                }
                else
                    GFX_PrintConsole("E: Could not create dir\n");
            }
            else
                GFX_PrintConsole("E: Filename too long\n");
        }
        else
            GFX_PrintConsole("E: Invalid path\n");
    }
    else
        GFX_PrintConsole("E: Invalid path\n");

    // restore path
    strcpy(SHELL_path, SHELL_pathBackup);
}

// Print help text
void SHELL_printHelp()
{
    GFX_PrintConsole("BDOS for FPGC\n");
    GFX_PrintConsole("Supported OS commands:\n");
    GFX_PrintConsole("- ./file [args]\n");
    GFX_PrintConsole("- CD     [arg1]\n");
    GFX_PrintConsole("- LS     [arg1]\n");
    GFX_PrintConsole("- PRINT  [arg1]\n");
    GFX_PrintConsole("- MKDIR  [arg1]\n");
    GFX_PrintConsole("- MKFILE [arg1]\n");
    GFX_PrintConsole("- RM     [arg1]\n");
    GFX_PrintConsole("- CLEAR\n");
    GFX_PrintConsole("- HELP\n");

    GFX_PrintConsole("\nExtra info:\n");
    GFX_PrintConsole("- Programs are executed form /BIN\n");
    GFX_PrintConsole("- Run LS /BIN to list all programs\n");
    GFX_PrintConsole("- Paths can be relative or absolute\n");
}


// Parses command line buffer and executes command if found
// Commands to parse:
// [x] ./ (RUN)
// [x] CD
// [x] LS
// [x] CLEAR
// [x] PRINT
// [x] MKDIR
// [x] MKFILE
// [x] RM
// [x] HELP
// [] RENAME
void SHELL_parseCommand(char* p)
{
    // ./ (RUN)
    // No commandCompare, because special case with no space
    if (p[0] == '.' && p[1] == '/' && p[2] != 0)
    {
        SHELL_runFile(p+2, 0); // pointer to start of filename, which ends with \0 or space
    }

    // LS
    else if (SHELL_commandCompare(p, "ls"))
    {
        word args = SHELL_numberOfArguments(p);
        // if incorrect number of arguments
        if (args > 1)
        {
            GFX_PrintConsole("E: Too many arguments\n");
            return;
        }
        else if (args == 1)
        {
            SHELL_ldir(p+3); // pointer to start of first arg, which ends with \0
        }
        else // if no args
        {
            SHELL_ldir("");
        }
    }

    // CD
    else if (SHELL_commandCompare(p, "cd"))
    {
        word args = SHELL_numberOfArguments(p);
        // if incorrect number of arguments
        if (args > 1)
        {
            GFX_PrintConsole("E: Too many arguments\n");
            return;
        }
        else if (args == 1)
        {
            // pointer to start of first arg, which ends with \0
            if (FS_changePath(p+3) != FS_ANSW_USB_INT_SUCCESS)
            {
                GFX_PrintConsole("E: Invalid path\n");
            }
        }
        else // if no args, go to root
        {
            // reset path variable to /
            SHELL_path[0] = '/';
            SHELL_path[1] = 0; // terminate string
        }

        // update path backup
        strcpy(SHELL_pathBackup, SHELL_path);
    }

    // CLEAR
    else if (SHELL_commandCompare(p, "clear"))
    {
        // clear screen by clearing window tables and resetting the cursor
        GFX_clearWindowtileTable();
        GFX_clearWindowpaletteTable();
        GFX_cursor = 0;
    }

    // PRINT
    else if (SHELL_commandCompare(p, "print"))
    {
        word args = SHELL_numberOfArguments(p);
        // if incorrect number of arguments
        if (args != 1)
        {
            GFX_PrintConsole("E: Expected 1 argument\n");
            return;
        }
        else
        {
            SHELL_printFile(p+6); // pointer to start of first arg, which ends with \0
        }
    }

    // RM
    else if (SHELL_commandCompare(p, "rm"))
    {
        word args = SHELL_numberOfArguments(p);
        // if incorrect number of arguments
        if (args != 1)
        {
            GFX_PrintConsole("E: Expected 1 argument\n");
            return;
        }
        else
        {
            SHELL_remove(p+3); // pointer to start of first arg, which ends with \0
        }
    }

    // MKFILE
    else if (SHELL_commandCompare(p, "mkfile"))
    {
        word args = SHELL_numberOfArguments(p);
        // if incorrect number of arguments
        if (args != 1)
        {
            GFX_PrintConsole("E: Expected 1 argument\n");
            return;
        }
        else
        {
            SHELL_createFile(p+7); // pointer to start of first arg, which ends with \0
        }
    }

    // MKDIR
    else if (SHELL_commandCompare(p, "mkdir"))
    {
        word args = SHELL_numberOfArguments(p);
        // if incorrect number of arguments
        if (args != 1)
        {
            GFX_PrintConsole("E: Expected 1 argument\n");
            return;
        }
        else
        {
            SHELL_createDir(p+6); // pointer to start of first arg, which ends with \0
        }
    }

    // HELP
    else if (SHELL_commandCompare(p, "help"))
    {
        SHELL_printHelp();
    }

    // No command
    else if (p[0] == 0)
    {
        // do nothing on enter
    }

    // Check if the command is in /BIN as a file
    else
    {
        // copy p to commandBuf but without the arguments
        char commandBuf[16]; // filenames cannot be larger than 12 characters anyways, so this should be enough
        word i = 0;
        commandBuf[0] = 0;
        while (p[i] != 0 && p[i] != ' ' && i < 15)
        {
            commandBuf[i] = p[i];
            i++;
        }
        commandBuf[i] = 0; // terminate buffer
        SHELL_runFile(commandBuf, 1);
        return;
    }
}


void SHELL_loop()
{
    if (HID_FifoAvailable())
    {
        word c = HID_FifoRead();

        // special keys, like arrow keys
        if (c > 255)
        {
            if (c == 258) // arrow up
            {
                SHELL_historyGoBack();
            }
            else if (c == 259) // arrow down
            {
                SHELL_historyGoForwards();
            }
        }
        else if (c == 0x8) // backspace
        {

            // replace last char in buffer by 0 (if not at start)
            if (SHELL_commandIdx != 0)
            {
                SHELL_commandIdx--;
                SHELL_command[SHELL_commandIdx] = 0;
            }

            // prevent removing characters from the shell prompt
            if (GFX_cursor > SHELL_promptCursorPos)
            {
                // print backspace to console to remove last typed character
                GFX_PrintcConsole(c);
            }
        }
        else if (c == 0x9) // tab
        {
            // do nothing for now when tab
        }
        else if (c == 0x1b) // escape
        {
            // do nothing for now when escape
        }
        else if (c == 0xa) // newline/enter
        {
            // reset history counter
            SHELL_historyMovedBackwards = 0;

            // append command to history
            SHELL_historyAppend();

            // start on new line
            GFX_PrintcConsole(c);

            // parse/execute command
            SHELL_parseCommand(SHELL_command);

            // clear buffer
            SHELL_clearCommand();

            // print shell prompt
            SHELL_print_prompt();
        }
        else
        {
            if (SHELL_commandIdx < SHELL_CMD_MAX_LENGTH)
            {
                // add to command buffer and print character
                SHELL_command[SHELL_commandIdx] = c;
                SHELL_commandIdx++;
                SHELL_command[SHELL_commandIdx] = 0; // terminate
                GFX_PrintcConsole(c);
            }
        }
    }
}

