/*
* Wiznet5500 library
* Contains functions to allow for networking
*
* Functions from this library can be used to operate up to 8 sockets
* Application based code should not be in this library
*/

#include "stdlib.h" 

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

#define WIZ_MAX_RBUF 2048 // buffer for receiving data (max rx packet size!)
#define WIZ_MAX_TBUF 2048 // buffer for sending data (max tx packet size!)


//-------------------
//BASIC READ AND WRITE FUNCTIONS
//-------------------

// Sets SPI3_CS low
void WizSpiBeginTransfer()
{
  ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC02732 r2          // r2 = 0xC02732 | SPI3_CS ;\
    \
    load 0 r1                   // r1 = 0 (enable) ;\
    write 0 r2 r1               // write to SPI3_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets SPI3_CS high
void WizSpiEndTransfer()
{
  ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC02732 r2          // r2 = 0xC02732 | SPI3_CS ;\
    \
    load 1 r1                   // r1 = 1 (disable) ;\
    write 0 r2 r1               // write to SPI3_CS ;\
    \
    // restore regs ;\
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
    load32 0xC02731 r1      // r1 = 0xC02731 | SPI3 address      ;\
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
void wizCmd(int s, int cmd)
{
  //wizWriteSingle(SnCR, WIZNET_WRITE_SnR, cmd);
  WizSpiBeginTransfer();
  WizSpiTransfer(0); //msByte
  WizSpiTransfer(SnCR); //lsByte
  WizSpiTransfer(WIZNET_WRITE_SnR + (s << 5));
  WizSpiTransfer(cmd);
  WizSpiEndTransfer();

  // wait untill done
  while ( wizReadSingle(SnCR, WIZNET_READ_SnR) );
}

// Write 8 bits to a sockets control register
void wizSetSockReg8(int s, int addr, int val)
{
  //wizWriteSingle(addr, WIZNET_WRITE_SnR, val);
  WizSpiBeginTransfer();
  WizSpiTransfer(0); //msByte
  WizSpiTransfer(addr); //lsByte
  WizSpiTransfer(WIZNET_WRITE_SnR + (s << 5));
  WizSpiTransfer(val);
  WizSpiEndTransfer();
}

// Read 8 bits from a sockets control register
int wizGetSockReg8(int s, int addr){
  //return wizReadSingle(addr, WIZNET_READ_SnR);
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  int cb = WIZNET_READ_SnR + (s << 5);
  
  // Send control byte
  WizSpiTransfer(cb);

  // Read data
  int retval = WizSpiTransfer(0);

  WizSpiEndTransfer();

  // Return read value
  return retval;
}

// Write 16 bits to a sockets control register
void wizSetSockReg16(int s, int addr, int val)
{
  //wizWriteDouble(addr, WIZNET_WRITE_SnR + (s << 5), val);
  WizSpiBeginTransfer();
  WizSpiTransfer(0); //msByte
  WizSpiTransfer(addr); //lsByte
  WizSpiTransfer(WIZNET_WRITE_SnR + (s << 5));
  int valMSB = val >> 8;
  WizSpiTransfer(valMSB);
  WizSpiTransfer(val);
  WizSpiEndTransfer();
}

// Read 16 bits from a sockets control register
int wizGetSockReg16(int s, int addr)
{
  //return wizReadDouble(addr, WIZNET_READ_SnR + (s << 5));
  WizSpiBeginTransfer();

  // Send address
  int addrMSB = addr >> 8;
  WizSpiTransfer(addrMSB); //msByte
  WizSpiTransfer(addr); //lsByte

  int cb = WIZNET_READ_SnR + (s << 5);

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
//W5500 SETUP FUNCTIONS
//-------------------

// Initialize W5500 chip
void wiz_Init(char* ip_addr, char* gateway_addr, char* mac_addr, char* sub_mask)
{
  WizSpiEndTransfer();
  delay(100);

  wizWrite(SIPR,  WIZNET_WRITE_COMMON,  ip_addr,       4);
  wizWrite(GAR,   WIZNET_WRITE_COMMON,  gateway_addr,  4);
  wizWrite(SHAR,  WIZNET_WRITE_COMMON,  mac_addr,      6);
  wizWrite(SUBR,  WIZNET_WRITE_COMMON,  sub_mask,      4);
}


// Initialize socket s for TCP
void wizInitSocketTCP(int s, int port)
{
  wizCmd(s, CR_CLOSE);
  wizSetSockReg8      (s, SnIR, 0xFF);    //reset interrupt register
  wizSetSockReg8      (s, SnMR, MR_TCP);  //set mode register to tcp
  wizSetSockReg16     (s, SnPORT, port);  //set tcp port
  wizCmd(s, CR_OPEN);
  wizCmd(s, CR_LISTEN);
  delay(10); //wait a bit to make sure the socket is in the correct state (technically not necessary)
}

// Initialize socket s for TCP client
void wizInitSocketTCPClient(int s, int port)
{
  wizCmd(s, CR_CLOSE);
  wizSetSockReg8      (s, SnIR, 0xFF);    //reset interrupt register
  wizSetSockReg8      (s, SnMR, MR_TCP);  //set mode register to tcp
  wizSetSockReg16     (s, SnPORT, port);  //set tcp port
  wizCmd(s, CR_OPEN);
  delay(10); //wait a bit to make sure the socket is in the correct state (technically not necessary)
}



//-------------------
//W5500 READING AND WRITING FUNCTIONS
//-------------------


int wizWriteDataFromMemory(int s, char* buf, int buflen)
{
  // Make sure there is something to send
  if (buflen <= 0)
  {
    return 0;
  }

  int bytesSent = 0;

  // loop until all bytes are sent
  while (bytesSent != buflen)
  {

    if (wizGetSockReg8(s, SnSR) == SOCK_CLOSED)
    {
      //uprintln("connection closed");
      return 0;
    }

    int partToSend = buflen - bytesSent;
    if (partToSend > WIZ_MAX_TBUF)
      partToSend = WIZ_MAX_TBUF;

    // Make sure there is room in the transmit buffer for what we want to send
    int txfree = wizGetSockReg16(s, SnTX_FSR); // Size of the available buffer area

    int timeout = 0;
    while (txfree < partToSend) 
    {
      timeout++; // Increase timeout counter
      delay(1); // Wait a bit
      txfree = wizGetSockReg16(s, SnTX_FSR); // Size of the available buffer area
      
      // After a second
      if (timeout > 1000) 
      {
        wizCmd(s, CR_DISCON); // Disconnect the connection
        //uprintln("timeout");
        return 0;
      }
    }

     // Space is available so we will send the buffer
    int txwr = wizGetSockReg16(s, SnTX_WR);  // Read the Tx Write Pointer

    // Write the outgoing data to the transmit buffer
    wizWrite(txwr, WIZNET_WRITE_SnTX + (s << 5), buf + bytesSent, partToSend);

    // update the buffer pointer
    int newSize = txwr + partToSend;
    wizSetSockReg16(s, SnTX_WR, newSize);

    // Now Send the SEND command which tells the wiznet the pointer is updated
    wizCmd(s, CR_SEND);

    // Update the amount of bytes sent
    bytesSent += partToSend;
  }


  return 1;
}



// Read received data
int wizReadRecvData(int s, char* buf, int buflen)
{
  if (buflen == 0)
  {
    return 1;
  }
  
  if (buflen > WIZ_MAX_RBUF) // If the request size > WIZ_MAX_RBUF, truncate it to prevent overflow
  {
    //uprintln("W: Received too large TCP data");
    buflen = WIZ_MAX_RBUF; // - 1; // -1 Because room for 0 terminator
  }
   
  // Get the address where the wiznet is holding the data
  int rxrd = wizGetSockReg16(s, SnRX_RD); 

  // Read the data into the buffer
  wizRead(rxrd, WIZNET_READ_SnRX + (s << 5), buf, buflen);

  // Remove read data from rxbuffer to make space for new data
  int nsize = rxrd + buflen;
    wizSetSockReg16(s, SnRX_RD, nsize);  //replace read data pointer
    //tell the wiznet we have retrieved the data
    wizCmd(s, CR_RECV);

  // Terminate buffer for printing in case the data was a string
  *(buf + buflen) = 0;

  return 1;
}


// Remove the received data
void wizFlush(int s, int rsize)
{
  if (rsize > 0)
  {
    int rxrd = wizGetSockReg16(s, SnRX_RD);         //retrieve read data pointer
    int nsize = rxrd + rsize;
    wizSetSockReg16(s, SnRX_RD, nsize);  //replace read data pointer
    //tell the wiznet we have retrieved the data
    wizCmd(s, CR_RECV);
  }
}
