; CH376 Library
; Allows for reading and writing USB drives with fat32 filesystem support

; TODO
; - GPO[1] to RST pin of CH376
; - changing and creating directories

`include lib/UART.asm
`include lib/SPI.asm
`include lib/STD.asm

define CMD_GET_IC_VER           =   0x01
define CMD_SET_BAUDRATE         =   0x02
define CMD_ENTER_SLEEP          =   0x03
define CMD_SET_USB_SPEED        =   0x04
define CMD_RESET_ALL            =   0x05
define CMD_CHECK_EXIST          =   0x06
define CMD_SET_SD0_INT          =   0x0b
define CMD_SET_RETRY            =   0x0b
define CMD_GET_FILE_SIZE        =   0x0c
define CMD_SET_USB_ADDRESS      =   0x13
define CMD_SET_USB_MODE         =   0x15
define MODE_HOST_0              =   0x05
define MODE_HOST_1              =   0x07
define MODE_HOST_2              =   0x06
define CMD_GET_STATUS           =   0x22
define CMD_RD_USB_DATA0         =   0x27
define CMD_WR_USB_DATA          =   0x2c
define CMD_WR_REQ_DATA          =   0x2d
define CMD_WR_OFS_DATA          =   0x2e
define CMD_SET_FILE_NAME        =   0x2f
define CMD_DISK_CONNECT         =   0x30
define CMD_DISK_MOUNT           =   0x31
define CMD_FILE_OPEN            =   0x32
define CMD_FILE_ENUM_GO         =   0x33
define CMD_FILE_CREATE          =   0x34
define CMD_FILE_ERASE           =   0x35
define CMD_FILE_CLOSE           =   0x36
define CMD_DIR_INFO_READ        =   0x37
define CMD_DIR_INFO_SAVE        =   0x38
define CMD_BYTE_LOCATE          =   0x39
define CMD_BYTE_READ            =   0x3a
define CMD_BYTE_RD_GO           =   0x3b
define CMD_BYTE_WRITE           =   0x3c
define CMD_BYTE_WR_GO           =   0x3d
define CMD_DISK_CAPACITY        =   0x3e
define CMD_DISK_QUERY           =   0x3f
define CMD_DIR_CREATE           =   0x40
define CMD_SET_ADDRESS          =   0x45
define CMD_GET_DESCR            =   0x46
define CMD_SET_CONFIG           =   0x49
define CMD_AUTO_CONFIG          =   0x4D
define CMD_ISSUE_TKN_X          =   0x4E
define ANSW_RET_SUCCESS         =   0x51
define ANSW_USB_INT_SUCCESS     =   0x14
define ANSW_USB_INT_CONNECT     =   0x15
define ANSW_USB_INT_DISCONNECT  =   0x16
define ANSW_USB_INT_USB_READY   =   0x18
define ANSW_USB_INT_DISK_READ   =   0x1d
define ANSW_USB_INT_DISK_WRITE  =   0x1e
define ANSW_RET_ABORT           =   0x5F
define ANSW_USB_INT_DISK_ERR    =   0x1f
define ANSW_USB_INT_BUF_OVER    =   0x17
define ANSW_ERR_OPEN_DIR        =   0x41
define ANSW_ERR_MISS_FILE       =   0x42
define ANSW_ERR_FOUND_NAME      =   0x43
define ANSW_ERR_DISK_DISCON     =   0x82
define ANSW_ERR_LARGE_SECTOR    =   0x84
define ANSW_ERR_TYPE_ERROR      =   0x92
define ANSW_ERR_BPB_ERROR       =   0xa1
define ANSW_ERR_DISK_FULL       =   0xb1
define ANSW_ERR_FDT_OVER        =   0xb2
define ANSW_ERR_FILE_CLOSE      =   0xb4
define ERR_LONGFILENAME         =   0x01
define ATTR_READ_ONLY           =   0x01
define ATTR_HIDDEN              =   0x02
define ATTR_SYSTEM              =   0x04
define ATTR_VOLUME_ID           =   0x08
define ATTR_DIRECTORY           =   0x10 
define ATTR_ARCHIVE             =   0x20

; Sets cursor to position in r1
; INPUT:
;   r1: cursor position
; OUTPUT:
;   r1: status code
CH376_Set_cursor:
    ; backup regs
    push r1
    push r2
    push r3

    or r1 r0 r3

    addr2reg CH376_String_Set_cursor r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text



    load CMD_BYTE_LOCATE r1

    savpc r15
    push r15
    jump SPI_transfer

    shiftr r3 24 r1

    savpc r15
    push r15
    jump SPI_transfer

    shiftr r3 16 r1

    savpc r15
    push r15
    jump SPI_transfer

    shiftr r3 8 r1

    savpc r15
    push r15
    jump SPI_transfer

    shiftr r3 0 r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Set_cursor_check_status:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Set_cursor_check_status

    or r3 r0 r1     ; set status code back to r1

    ; restore regs
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15

; Read from file to buffer address.
; Writes read bytes directly after each other (4 in a word)
; INPUT:
;   r1: address of buffer to write to
;   r2: length of data to read, max 255
; OUTPUT:
;   r1: status code
CH376_Read_file:
    ; backup regs
    push r2
    push r3
    push r4
    push r5
    push r6

    or r2 r0 r4             ; backup length
    or r1 r0 r5             ; backup data address

    addr2reg CH376_String_Read_file r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_BYTE_READ r1

    savpc r15
    push r15
    jump SPI_transfer

    or r4 r0 r1

    savpc r15
    push r15
    jump SPI_transfer

    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Read_file_check_status:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Read_file_check_status

    load CMD_RD_USB_DATA0 r1

    savpc r15
    push r15
    jump SPI_transfer

    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg

    load 32 r6                  ; r6 = shift variable
    write 0 r5 r0               ; clear first address of buffer

    CH376_Read_file_write_away:
        ; end copying when done reading (when r4 reached 0)
        bne r0 r4 2
            jump CH376_Read_file_write_away_done

        load 0x00 r1
        savpc r15
        push r15
        jump SPI_transfer

        sub r6 8 r6             ; remove 8 from shift variable
        shiftl r1 r6 r1         ; shift to left
        ; write away
        read 0 r5 r2
        or r1 r2 r2
        write 0 r5 r2 

        bne r0 r6 6             ; if we shifted the last byte
            add r5 1 r5             ; increase address
            load 1 r1
            beq r1 r4 2
                write 0 r5 r0           ; clear next address of buffer
            load 32 r6              ; set shift variable back to 32

        ; go read next byte
        sub r4 1 r4
        jump CH376_Read_file_write_away

    CH376_Read_file_write_away_done:

    ; copy status code to return address
    or r3 r0 r1

    ; restore regs
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15

; Writes to file
; INPUT:
;   r1: address of first byte to write
;   r2: length of data to write, max 255
; OUTPUT:
;   r1: status code
CH376_Write_file:
    ; backup regs
    push r2
    push r3
    push r4
    push r5
    push r6

    or r2 r0 r4             ; backup length
    or r1 r0 r5             ; backup data address

    addr2reg CH376_String_Request_write r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text


    load CMD_BYTE_WRITE r1

    savpc r15
    push r15
    jump SPI_transfer

    or r4 r0 r1

    savpc r15
    push r15
    jump SPI_transfer

    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Write_file_check_status:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Write_file_check_status


    addr2reg CH376_String_Write_data r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_WR_REQ_DATA r1

    savpc r15
    push r15
    jump SPI_transfer

    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg


    or r4 r0 r2             ; write length back to r2
    or r5 r0 r1             ; write data address back to r1

    load 0 r5               ; r5 = loopvar
    load 32 r6              ; r6 = shift variable

    load32 0xC02631 r3      ; r3 = 0xC02631 | SPI address

    ; copy loop
    CH376_Write_file_loop:
        sub r6 8 r6             ; remove 8 from shift variable
        read 0 r1 r4            ; read 32 bits
        shiftr r4 r6 r4         ; shift to right

        savpc r15
        push r15
        jump SPI_beginTransfer
        write 0 r3 r4           ; send char over SPI
        savpc r15
        push r15
        jump SPI_endTransfer

        bne r0 r6 3             ; if we shifted the last byte
            add r1 1 r1             ; incr data address 
            load 32 r6              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all chars are written
        jump CH376_Write_file_loop

    savpc r15
    push r15
    jump SPI_endTransfer


    addr2reg CH376_String_Write_WR_go r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text


    load CMD_BYTE_WR_GO r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Write_file_WR_check_status:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Write_file_WR_check_status

    or r3 r0 r1     ; set status code back to r1

    ; restore regs
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15

; Opens file
; OUTPUT:
;   r1: status code
CH376_Open_file:
    ; backup regs
    push r2
    push r3

    ; opening file
    addr2reg CH376_String_Opening_file r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_FILE_OPEN r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Open_file_check_opened:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Open_file_check_opened
        
    ; move status code back to r1
    or r3 r0 r1

    ; restore regs
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Closes file
; OUTPUT:
;   r1: status code
CH376_Close_file:
    ; backup regs
    push r2
    push r3

    ; opening file
    addr2reg CH376_String_Closing_file r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_FILE_CLOSE r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Open_file_check_closed:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Open_file_check_closed
        
    ; move status code back to r1
    or r3 r0 r1

    ; restore regs
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Creates file
; OUTPUT:
;   r1: status code
CH376_Create_file:
    ; backup regs
    push r2
    push r3

    ; opening file
    addr2reg CH376_String_Creating_file r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_FILE_CREATE r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Open_file_check_created:
        ; get status
        savpc r15
        push r15
        jump CH376_Get_status

        ; copy status code to r3
        or r1 r0 r3

        ; print received char over uart
        savpc r15
        push r15
        jump STD_Byte2_to_Hex

        savpc r15
        push r15
        jump UART_print_reg

        ; keep checking until response
        load CMD_GET_STATUS r2
        bne r3 r2 5
            savpc r15
            push r15
            jump CH376_Delay_100ms
            jump CH376_Open_file_check_created
        
    ; move status code back to r1
    or r3 r0 r1

    ; restore regs
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Send filename
; INPUT:
;   r1: address of filename
;   r2: length of filename
CH376_Send_filename:
    ; backup regs
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6

    savpc r15
    push r15
    jump SPI_beginTransfer

    load32 0xC02631 r3      ; r3 = 0xC02631 | SPI address     

    load CMD_SET_FILE_NAME r4
    write 0 r3 r4
    load 47 r4              ; '/'
    write 0 r3 r4

    load 0 r5               ; r5 = loopvar
    load 32 r6              ; r6 = shift variable

    ; copy loop
    CH376_Send_filename_loop:
        sub r6 8 r6             ; remove 8 from shift variable
        read 0 r1 r4            ; read 32 bits
        shiftr r4 r6 r4         ; shift to right
        write 0 r3 r4           ; send char over SPI

        bne r0 r6 3             ; if we shifted the last byte
            add r1 1 r1             ; incr data address 
            load 32 r6              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all chars are written
        jump CH376_Send_filename_loop

    write 0 r3 r0           ; end with 0x00

    savpc r15
    push r15
    jump SPI_endTransfer

    addr2reg CH376_String_Sent_filename r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; restore regs
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15

 
; Initialize CH376 module
CH376_init:
    ; backup regs
    push r1
    push r2
    push r3

    ; initialize cs as high by using SPI_endTransfer
    savpc r15
    push r15
    jump SPI_endTransfer

    addr2reg CH376_String_Init r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; reset
    savpc r15
    push r15
    jump CH376_Reset

    ; set usb mode
    savpc r15
    push r15
    jump CH376_Set_USB_Mode

    ; set mode host 0
    savpc r15
    push r15
    jump CH376_Set_Mode_Host_0

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg

    addr2reg CH376_String_Init_done r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; restore regs
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15
    
 
; Check drive connection and mount
CH376_Check_drive:
    ; backup regs
    push r1
    push r2
    push r3

    addr2reg CH376_String_Checking_connection r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    CH376_Check_drive_check_connection:
    ; get status
    savpc r15
    push r15
    jump CH376_Get_status

    ; copy status code to r3
    or r1 r0 r3

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg

    ; keep checking until device connected
    load ANSW_USB_INT_CONNECT r2
    beq r3 r2 5
        savpc r15
        push r15
        jump CH376_Delay_100ms
        jump CH376_Check_drive_check_connection


    ; wait a bit so device is properly connected
    savpc r15
    push r15
    jump CH376_Delay_100ms

    ; set usb mode
    savpc r15
    push r15
    jump CH376_Set_USB_Mode

    ; set mode host 1
    savpc r15
    push r15
    jump CH376_Set_Mode_Host_1

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg


    ; set usb mode
    savpc r15
    push r15
    jump CH376_Set_USB_Mode

    ; set mode host 2
    savpc r15
    push r15
    jump CH376_Set_Mode_Host_2

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg


    ; checking for drive in new usb mode
    addr2reg CH376_String_Checking_connection r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    CH376_Check_drive_check_connection_2:
    ; get status
    savpc r15
    push r15
    jump CH376_Get_status

    ; copy status code to r3
    or r1 r0 r3

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg

    ; keep checking until device connected
    load ANSW_USB_INT_CONNECT r2
    beq r3 r2 5
        savpc r15
        push r15
        jump CH376_Delay_100ms
        jump CH376_Check_drive_check_connection_2


    ; wait a bit so device is properly connected
    savpc r15
    push r15
    jump CH376_Delay_100ms


    ; check if drive is ready
    addr2reg CH376_String_Checking_drive_ready r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_DISK_CONNECT r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Check_drive_check_ready:
    ; get status
    savpc r15
    push r15
    jump CH376_Get_status

    ; copy status code to r3
    or r1 r0 r3

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg

    ; keep checking until device ready
    load ANSW_USB_INT_SUCCESS r2
    beq r3 r2 5
        savpc r15
        push r15
        jump CH376_Delay_100ms
        jump CH376_Check_drive_check_ready


    ; mounting drive
    addr2reg CH376_String_Mounting_drive r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    load CMD_DISK_MOUNT r1

    savpc r15
    push r15
    jump SPI_transfer

    CH376_Check_drive_check_mounted:
    ; get status
    savpc r15
    push r15
    jump CH376_Get_status

    ; copy status code to r3
    or r1 r0 r3

    ; print received char over uart
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    savpc r15
    push r15
    jump UART_print_reg

    ; keep checking until drive mounted
    load ANSW_USB_INT_SUCCESS r2
    beq r3 r2 5
        savpc r15
        push r15
        jump CH376_Delay_100ms
        jump CH376_Check_drive_check_mounted
        

    ; restore regs
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Get status by sending CMD_GET_STATUS and returning result
; OUTPUT:
;   r1: Received status code
CH376_Get_status:
    ; backup regs
    push r2

    load CMD_GET_STATUS r1

    savpc r15
    push r15
    jump SPI_transfer

    savpc r15
    push r15
    jump CH376_Delay_40us

    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; restore regs
    pop r2

    ; return
    pop r15
    jumpr 3 r15

; Send CMD_RESET_ALL and wait
CH376_Reset:
    ; backup regs
    push r1
    push r2

    load CMD_RESET_ALL r1

    savpc r15
    push r15
    jump SPI_transfer

    savpc r15
    push r15
    jump CH376_Delay_100ms

    addr2reg CH376_String_Reset_done r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; restore regs
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Set USB mode and wait a 40us
CH376_Set_USB_Mode:
    ; backup regs
    push r1
    push r2

    load CMD_SET_USB_MODE r1

    savpc r15
    push r15
    jump SPI_transfer

    savpc r15
    push r15
    jump CH376_Delay_40us

    addr2reg CH376_String_USB_mode_set r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; restore regs
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Set mode host 0, wait 40us and read status
; OUTPUT:
;   r1: Received status code
CH376_Set_Mode_Host_0:
    ; backup regs
    push r2
    push r3

    load MODE_HOST_0 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; delay 40us
    savpc r15
    push r15
    jump CH376_Delay_40us

    ; print to uart
    addr2reg CH376_String_Mode_Host_0_set r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; read from SPI
    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; restore regs
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Set mode host 1, wait 40us and read status
; OUTPUT:
;   r1: Received status code
CH376_Set_Mode_Host_1:
    ; backup regs
    push r2
    push r3

    load MODE_HOST_1 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; delay 40us
    savpc r15
    push r15
    jump CH376_Delay_40us

    ; print to uart
    addr2reg CH376_String_Mode_Host_1_set r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; read from SPI
    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; restore regs
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Set mode host 2, wait 40us and read status
; OUTPUT:
;   r1: Received status code
CH376_Set_Mode_Host_2:
    ; backup regs
    push r2
    push r3

    load MODE_HOST_2 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; delay 40us
    savpc r15
    push r15
    jump CH376_Delay_40us

    ; print to uart
    addr2reg CH376_String_Mode_Host_2_set r1
    read 0 r1 r2
    add r1 1 r1
    savpc r15
    push r15
    jump UART_print_text

    ; read from SPI
    load 0x00 r1

    savpc r15
    push r15
    jump SPI_transfer

    ; restore regs
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Delay 100ms
; ~.5us per instruction
; 200.000 instructions to wait 100ms
CH376_Delay_100ms:
    ; backup regs
    push r1
    push r2

    load32 0x1046A r1           ; r1 = loop max, 200.000/3 = 66.666    
    load 0 r2                   ; r2 = loopvar

    ; delay loop
    CH376_Delay_100ms_loop:
        add r2 1 r2             ; incr counter
        bge r2 r1 2             ; keep looping until all iteration done
        jump CH376_Delay_100ms_loop


    ; restore regs
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Delay 40us
; ~.5us per instruction
; 80 instructions to wait 40us
CH376_Delay_40us:
    ; backup regs
    push r1
    push r2

    load 27 r1                  ; r1 = loop max, 80/3 = 27
    load 0 r2                   ; r2 = loopvar

    ; delay loop
    CH376_Delay_40us_loop:
        add r2 1 r2             ; incr counter
        bge r2 r1 2             ; keep looping until all iteration done
        jump CH376_Delay_40us_loop


    ; restore regs
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Static strings
; starts with .dw which contains the length of the string

CH376_String_Init:
.dw 4
.ds "Init"

CH376_String_Init_done:
.dw 9
.ds "Init done"

CH376_String_Checking_drive:
.dw 14
.ds "Checking drive"

CH376_String_Checking_connection:
.dw 25
.ds "Checking drive connection"

CH376_String_Checking_status:
.dw 21
.ds "Checking drive status"

CH376_String_Checking_drive_ready:
.dw 26
.ds "Checking if drive is ready"

CH376_String_Mounting_drive:
.dw 14
.ds "Mounting drive"

CH376_String_Reset_done:
.dw 12
.ds "Device reset"

CH376_String_USB_mode_set:
.dw 12
.ds "USB mode set"

CH376_String_Mode_Host_0_set:
.dw 18
.ds "Host mode set to 0"

CH376_String_Mode_Host_1_set:
.dw 18
.ds "Host mode set to 1"

CH376_String_Mode_Host_2_set:
.dw 18
.ds "Host mode set to 2"

CH376_String_Sent_filename:
.dw 13
.ds "Filename sent"

CH376_String_Opening_file:
.dw 12
.ds "Opening file"

CH376_String_Closing_file:
.dw 12
.ds "Closing file"

CH376_String_Creating_file:
.dw 13
.ds "Creating file"

CH376_String_Deleting_file:
.dw 13
.ds "Deleting file"

CH376_String_Request_write:
.dw 16
.ds "Requesting write"

CH376_String_Write_data:
.dw 10
.ds "Write data"

CH376_String_Write_WR_go:
.dw 18
.ds "Updating file size"

CH376_String_Set_cursor:
.dw 14
.ds "Setting cursor"

CH376_String_Read_file:
.dw 9
.ds "Read file"

