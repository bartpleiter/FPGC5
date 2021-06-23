#include "lib/stdlib.h" 

// Wiznet W5500 Op Codes
#define WIZNET_WRITE_COMMON 0x04 //opcode to write to one of the common block of registers
#define WIZNET_READ_COMMON  0x00 //opcode to read one of the common block of registers
#define WIZNET_WRITE_SnR    0x0C // s<<5 (nnn 01 1 00) opcode to write to one of the socket n registers
#define WIZNET_READ_SnR     0x08 // s<<5 (nnn 01 0 00) opcode to read one of the socket n registers
#define WIZNET_WRITE_SnTX   0x14 // s<<5 (nnn 10 1 00) opcode to write to the socket n transmit buffer
#define WIZNET_READ_SnRX    0x18 // s<<5 (nnn 11 0 00) opcode to read from the socket n receive buffer

// Wiznet W5500 Register Addresses
#define MR     0x0000    // Mode
#define GAR    0x0001    // Gateway IP address
#define SUBR   0x0005    // Subnet mask address
#define SHAR   0x0009    // Source MAC address
#define SIPR   0x000F    // Source IP address
#define IR     0x0015    // Interrupt
#define IMR    0x0016    // Interrupt Mask
#define RTR    0x0019    // Timeout address
#define RCR    0x001B    // Retry count
#define UIPR   0x0028    // Unreachable IP address in UDP mode
#define UPORT  0x002C    // Unreachable Port address in UDP mode

//W5500 Socket Registers follow
#define SnMR        0x0000        // Mode
#define SnCR        0x0001        // Command
#define SnIR        0x0002        // Interrupt
#define SnSR        0x0003        // Status
#define SnPORT      0x0004        // Source Port (2 bytes)
#define SnDHAR      0x0006        // Destination Hardw Addr
#define SnDIPR      0x000C        // Destination IP Addr
#define SnDPORT     0x0010        // Destination Port
#define SnMSSR      0x0012        // Max Segment Size
#define SnPROTO     0x0014        // Protocol in IP RAW Mode
#define SnTOS       0x0015        // IP TOS
#define SnTTL       0x0016        // IP TTL
#define SnRX_BSZ    0x001E        // RX Buffer Size
#define SnTX_BSZ    0x001F        // TX Buffer Size
#define SnTX_FSR    0x0020        // TX Free Size
#define SnTX_RD     0x0022        // TX Read Pointer
#define SnTX_WR     0x0024        // TX Write Pointer
#define SnRX_RSR    0x0026        // RX RECEIVED SIZE REGISTER
#define SnRX_RD     0x0028        // RX Read Pointer
#define SnRX_WR     0x002A        // RX Write Pointer (supported?

//Socket n Mode Register (0x0000)
//SnMR
#define MR_CLOSE    0x00    // Unused socket
#define MR_TCP      0x01    // TCP
#define MR_UDP      0x02    // UDP
#define MR_IPRAW    0x03    // IP LAYER RAW SOCK
#define MR_MACRAW   0x04    // MAC LAYER RAW SOCK
#define MR_PPPOE    0x05    // PPPoE
#define MR_ND       0x20    // No Delayed Ack(TCP) flag
#define MR_MULTI    0x80    // support multicating

//Socket n Command Register (0x0001)
//SnCR
#define CR_OPEN          0x01   // Initialize or open socket
#define CR_LISTEN        0x02   // Wait connection request in tcp mode(Server mode)
#define CR_CONNECT       0x04   // Send connection request in tcp mode(Client mode)
#define CR_DISCON        0x08   // Send closing reqeuset in tcp mode
#define CR_CLOSE         0x10   // Close socket
#define CR_SEND          0x20   // Update Tx memory pointer and send data
#define CR_SEND_MAC      0x21   // Send data with MAC address, so without ARP process
#define CR_SEND_KEEP     0x22   // Send keep alive message
#define CR_RECV          0x40   // Update Rx memory buffer pointer and receive data

//Socket n Interrupt Register (0x0002)
//SnIR
// Bit 0: CON
// Bit 1: DISCON
// Bit 2: RECV
// Bit 3: TIMEOUT
// Bit 4: SEND_OK

//Socket n Status Register (0x0003)
//SnSR 
#define SOCK_CLOSED      0x00   // Closed
#define SOCK_INIT        0x13   // Init state
#define SOCK_LISTEN      0x14   // Listen state
#define SOCK_SYNSENT     0x15   // Connection state
#define SOCK_SYNRECV     0x16   // Connection state
#define SOCK_ESTABLISHED 0x17   // Success to connect
#define SOCK_FIN_WAIT    0x18   // Closing state
#define SOCK_CLOSING     0x1A   // Closing state
#define SOCK_TIME_WAIT   0x1B   // Closing state
#define SOCK_CLOSE_WAIT  0x1C   // Closing state
#define SOCK_LAST_ACK    0x1D   // Closing state
#define SOCK_UDP         0x22   // UDP socket
#define SOCK_IPRAW       0x32   // IP raw mode socket
#define SOCK_MACRAW      0x42   // MAC raw mode socket
#define SOCK_PPPOE       0x5F   // PPPOE socket

//Socket n Source Port Register (0x0004, 0x0005)
//SnPORT
// MSByte: 0x0004
// LSByte: 0x0005

#define WIZ_MAX_BUF 512


//-------------------
//BASIC READ AND WRITE FUNCTIONS
//-------------------

// Sets GPO[1] (cs) low
void WizSpiBeginTransfer()
{
  ASM("\
  // backup regs ;\
    push r1 ;\
    push r2 ;\
    push r3 ;\
    \
    load32 0xC02630 r3          // r3 = 0xC02630 | GPIO ;\
    \
    read 0 r3 r1                // r1 = GPIO values ;\
    load 0b1111110111111111 r2  // r2 = bitmask ;\
    and r1 r2 r1                // set GPO[1] low ;\
    write 0 r3 r1               // write GPIO ;\
    \
    // restore regs ;\
    pop r3 ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets GPO[1] (cs) high
void WizSpiEndTransfer()
{
  ASM("\
  // backup regs ;\
    push r1 ;\
    push r2 ;\
    push r3 ;\
    \
    load32 0xC02630 r3          // r3 = 0xC02630 | GPIO ;\
    \
    read 0 r3 r1                // r1 = GPIO values ;\
    load 0b1000000000 r2        // r2 = bitmask ;\
    or r1 r2 r1                 // set GPO[1] high ;\
    write 0 r3 r1               // write GPIO ;\
    \
    // restore regs ;\
    pop r3 ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI to Wiznet chip
// INPUT:
//   r5: byte to write
// OUTPUT:
//   r1: read value
int WizSpiTransfer(int dataByte)
{
  ASM("\
    load32 0xC02734 r1      // r1 = 0xC02734 | SPI2 address      ;\
    write 0 r1 r5           // write r5 over SPI        ;\
    read 0 r1 r1            // read return value        ;\
    ");
}


// Write data to W5500
void wizWrite(int addr, int cb, char* buf, int len)
{
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  // Send control byte
  WizSpiTransfer(cb);

  // Send data
  for (int i = 0; i < len; i++)
  {
    WizSpiTransfer(buf[i]);
  }

  WizSpiEndTransfer();
}


// Write single byte to W5500
int wizWriteSingle(int addr, int cb, int data)
{
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  // Send control byte
  WizSpiTransfer(cb);

  // Send data
  WizSpiTransfer(data);

  WizSpiEndTransfer();

  return data;
}


// Write two bytes to W5500
void wizWriteDouble(int addr, int cb, int data)
{
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  // Send control byte
  WizSpiTransfer(cb);

  // Send data
  int dataMSB = data >> 8;
  WizSpiTransfer(dataMSB);
  WizSpiTransfer(data);

  WizSpiEndTransfer();
}


void wizRead(int addr, int cb, char* buf, int len)
{ 
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  // Send control byte
  WizSpiTransfer(cb);

  // Read data
  for (int i = 0; i < len; i++)
  {
    buf[i] = WizSpiTransfer(0);
  }

  WizSpiEndTransfer();
}


int wizReadSingle(int addr, int cb)
{ 
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  // Send control byte
  WizSpiTransfer(cb);

  // Read data
  int retval = WizSpiTransfer(0);

  WizSpiEndTransfer();

  // Return read value
  return retval;
}


int wizReadDouble(int addr, int cb)
{ 
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  // Send control byte
  WizSpiTransfer(cb);

  // Read data
  int retval = WizSpiTransfer(0) << 8;
  retval = retval + WizSpiTransfer(0);

  WizSpiEndTransfer();

  // Return read value
  return retval;
}


//-------------------
//W5500 SOCKET REGISTER FUNCTIONS
//-------------------

// Send a command cmd to socket s
// Wait until done
void wizCmd(int cmd)
{
  //wizWriteSingle(SnCR, WIZNET_WRITE_SnR, cmd);
  WizSpiBeginTransfer();
  WizSpiTransfer(0); //msByte
  WizSpiTransfer(SnCR); //lsByte
  WizSpiTransfer(WIZNET_WRITE_SnR);
  WizSpiTransfer(cmd);
  WizSpiEndTransfer();

  while ( wizReadSingle(SnCR, WIZNET_READ_SnR) );
}

// Write 8 bits to a sockets control register
void wizSetSockReg8(int addr, int val)
{
  //wizWriteSingle(addr, WIZNET_WRITE_SnR, val);
  WizSpiBeginTransfer();
  WizSpiTransfer(0); //msByte
  WizSpiTransfer(addr); //lsByte
  WizSpiTransfer(WIZNET_WRITE_SnR);
  WizSpiTransfer(val);
  WizSpiEndTransfer();
}

// Read 8 bits from a sockets control register
int wizGetSockReg8(int addr){
  return wizReadSingle(addr, WIZNET_READ_SnR);
}

// Write 16 bits to a sockets control register
void wizSetSockReg16(int addr, int val)
{
  //wizWriteDouble(addr, WIZNET_WRITE_SnR, val);
  WizSpiBeginTransfer();
  WizSpiTransfer(0); //msByte
  WizSpiTransfer(addr); //lsByte
  WizSpiTransfer(WIZNET_WRITE_SnR);
  int valMSB = val >> 8;
  WizSpiTransfer(valMSB);
  WizSpiTransfer(val);
  WizSpiEndTransfer();
}

// Read 16 bits from a sockets control register
int wizGetSockReg16(int addr)
{
  return wizReadDouble(addr, WIZNET_READ_SnR);
}


//-------------------
//W5500 CONNECTION HANDLING FUNCTIONS
//-------------------

int wizWriteResponse(char* buf, int buflen)
{
  // Make sure there is something to send
  if (buflen <= 0)
  {
    return 0;
  }

  // Make sure there is room in the transmit buffer for what we want to send
  int txfree = wizGetSockReg16(SnTX_FSR); // Size of the available buffer area

  int timeout = 0;
  while (txfree < buflen) 
  {
    timeout++; // Increase timeout counter
    delay(1); // Wait a bit
    txfree = wizGetSockReg16(SnTX_FSR); // Size of the available buffer area
    
    // After a second
    if (timeout > 1000) 
    {
      wizCmd(CR_DISCON); // Disconnect the connection
      return 0;
    }
  }

  // Space is available so we will send the buffer
  int txwr = wizGetSockReg16(SnTX_WR);  // Read the Tx Write Pointer

  // Write the outgoing data to the transmit buffer
  wizWrite(txwr, WIZNET_WRITE_SnTX, buf, buflen);

  // update the buffer pointer
  int newSize = txwr + buflen;
  wizSetSockReg16(SnTX_WR, newSize);

  // Now Send the SEND command which tells the wiznet the pointer is updated
  wizCmd(CR_SEND);

  return 1;
}


// Read received data
int wizReadRecvData(char* buf, int buflen)
{
  if (buflen == 0)
  {
    return 1;
  }
  if (buflen > WIZ_MAX_BUF) // If the request size > WIZ_MAX_BUF,just truncate it
  {
    buflen = WIZ_MAX_BUF - 2; // -2 Because room for 0 terminator and because arrays start at 0
  }
   
  // Get the address where the wiznet is holding the data
  int rxrd = wizGetSockReg16(SnRX_RD); 

  // Read the data into the buffer
  wizRead(rxrd, WIZNET_READ_SnRX, buf, buflen);

  // Terminate buffer
  *(buf + buflen) = 0;

  return 1;
}


// Remove the received data when not wanting to read it
void wizFlush(int s, int rsize)
{
  if (rsize > 0)
  {
    int rxrd = wizGetSockReg16(SnRX_RD);         //retrieve read data pointer
    int nsize = rxrd + rsize;
    wizSetSockReg16(SnRX_RD, nsize);  //replace read data pointer
    //tell the wiznet we have retrieved the data
    wizCmd(CR_RECV);
  }
}


void wizSendResponse()
{
  char* retTxt = "<div align=\"center\"><FONT color=\"#ffffff\" size=\"99\"><MARQUEE bgcolor=\"#000080\" direction=\"left\" loop=\"20\" width=\"75%\"><STRONG>Deze site wordt gehost op een FPGC4</STRONG></MARQUEE></FONT></DIV>";
  wizWriteResponse(retTxt, 192);
}


// Handle session for socket s
void wizHandleSession()
{
  // Size of received data
  int rsize;
  rsize = wizGetSockReg16(SnRX_RSR);

  if (rsize > 0)
  {
    
    char tmpbuf[WIZ_MAX_BUF];
    tmpbuf[0] = 0;
    wizReadRecvData(&tmpbuf[0], rsize);
    uprintln("---START REQUEST---");
    uprintln(&tmpbuf[0]);
    uprintln("---END REQUEST---");

    // choose: send back response as text, or send back static text
    wizWriteResponse(&tmpbuf[0], rsize);
    //wizSendResponse();
    
    // Free received data when not read
    //wizFlush(0, rsize);
  }

  // Disconnect after sending a response
  wizCmd(CR_DISCON);
}


//-------------------
//W5500 SETUP FUNCTIONS
//-------------------

// Initialize W5500 chip
void wiz_Init()
{
  char i;

  char ip_addr[4];
  i = 192;
  ip_addr[0] = i;
  i = 168;
  ip_addr[1] = i;
  i = 0;
  ip_addr[2] = i;
  i = 213;
  ip_addr[3] = i;
 
  char gateway_addr[4];
  i = 192;
  gateway_addr[0] = i;
  i = 168;
  gateway_addr[1] = i;
  i = 0;
  gateway_addr[2] = i;
  i = 1;
  gateway_addr[3] = i;

  char mac_addr[6];
  i = 0xDE;
  mac_addr[0] = i;
  i = 0xAD;
  mac_addr[1] = i;
  i = 0xBE;
  mac_addr[2] = i;
  i = 0xEF;
  mac_addr[3] = i;
  i = 0x24;
  mac_addr[4] = i;
  i = 0x64;
  mac_addr[5] = i;

  char sub_mask[4];
  i = 255;
  sub_mask[0] = i;
  i = 255;
  sub_mask[1] = i;
  i = 255;
  sub_mask[2] = i;
  i = 0;
  sub_mask[3] = i;

  wizWrite(SIPR,  WIZNET_WRITE_COMMON,  &ip_addr[0],       4);
  delay(10);
  wizWrite(GAR,   WIZNET_WRITE_COMMON,  &gateway_addr[0],  4);
  delay(10);
  wizWrite(SHAR,  WIZNET_WRITE_COMMON,  &mac_addr[0],      6);
  delay(10);
  wizWrite(SUBR,  WIZNET_WRITE_COMMON,  &sub_mask[0],      4);
  delay(10);
  uprintln("Init done");
}


// Initialize socket 0 for TCP listen at 80.
void wizInitSocketTCP()
{
    wizCmd(CR_CLOSE);
    wizSetSockReg8      (SnIR, 0xFF);    //reset interrupt register
    wizSetSockReg8      (SnMR, MR_TCP);  //set mode register to tcp
    wizSetSockReg16     (SnPORT, 80);  //set tcp port to 80
    wizCmd(CR_OPEN);
    wizCmd(CR_LISTEN);

    uprintln("opened socket");
}


//-------------------
//W5500 MAIN CODE
//-------------------

int main() 
{
  WizSpiEndTransfer();
  delay(100);

  // Init W5500
  wiz_Init();

  wizInitSocketTCP();
  
  // Socket 0 status
  int s0Status;

  while(1)
  {
    // Get status for socket 0
    s0Status = wizGetSockReg8(SnSR);

    if (s0Status == SOCK_CLOSED)
    { 
      // Open the socket when closed
      uprintln("Socket closed");
      // Set socket 0 in TCP Server mode at port 80
      wizInitSocketTCP();
    }
    else if (s0Status == SOCK_ESTABLISHED)
    {
      // Handle session when a connection is established
      // Also reinitialize socket
      uprintln("Got connection");
      wizHandleSession();
      // Set socket 0 in TCP Server mode at port 80
      wizInitSocketTCP();
    }
    else if (s0Status == SOCK_LISTEN)
    {
      // Do nothing when listening for connections
    }
    else
    {
      // In other cases, reset the socket
      // Set socket 0 in TCP Server mode at port 80
      uprintln("Resetting socket");
      wizInitSocketTCP();
    }

    // Delay a few milliseconds
    // Should (could) eventually be replaced by an interrupt checker
    delay(10);
  }
}

// timer1 interrupt handler
void int1()
{
   int *p = (int *) 0x4C0000; // set address (timer1 state)
   *p = 1; // write value
}

void int2()
{
}

void int3()
{
}

void int4()
{
}