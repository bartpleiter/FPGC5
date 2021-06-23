/**
 * ESP32Synth
 * 
 * TODO:
 * create exponential scale for adsr knob values (only calculated when knob is rotated, so no lookup tables needed!)
 * use multiple wavetables with aliasing for specific octaves
 * implement all missing features like FM, LFO, Reverb and Low/Hi pass
 */


/*
 * INCLUDES
 */
// I2S DAC
#include "driver/i2s.h"
#include "freertos/queue.h"

// Note ID to frequency table
#include "MidiTable.h"  

// ADSR exponential tables (length and max value of 4096)
#include "ExpTable.h"

// Wave tables (amplitude of +-2048)
#include "Sinus2048Int.h"
#include "Saw2048Int.h"
#include "Tri2048Int.h"


/*
 * DEFINITIONS AND VARIABLES
 */

//------------ MIDI INPUT -------------
HardwareSerial MidiSerial(2);         // MIDI input (and control output (TBI)) on UART2


//----------- WAVE TABLES -------------
// length of wavetables (must be a power of 2)
#define WAVETABLELENGTH 2048

// wave selection IDs
#define SQR  0    // square
#define SAW  1    // sawtooth
#define TRI  2    // triangle
#define SIN  3    // sinus
#define FM  4     // FM waves (TBI)
#define WMAX  5   // number of waves

uint32_t waveForm = SAW;          // currently selected waveform
uint32_t pwmWidth = 1024;         // width of square wave (0-2047)


//------------ ADSR --------------
// ADSR state codes
#define ADSR_IDLE      0
#define ADSR_ATTACK    1
#define ADSR_DECAY     2
#define ADSR_SUSTAIN   3
#define ADSR_RELEASE   4

// Max time for attack, decay and release in seconds
#define ADSR_MAXATTACKTIME    3
#define ADSR_MAXRELEASETIME   6
#define ADSR_MAXDECAYTIME     8

uint32_t AmaxCount  = 0;    // number of counts within attack state (duration in samples)
uint32_t DmaxCount  = 0;    // number of counts within decay state (duration in samples)
uint32_t RmaxCount  = 0;    // number of counts within release state (duration in samples)
uint32_t Sval       = 4095; // sustain value
bool SustainPedal = false;

// ADSR data structure
typedef struct {
  uint32_t state;           // current ADSR state
  uint32_t counter;         // counter for calculations within current ADSR state
  uint32_t output;          // output of ADSR, has range of 0-4095
  uint32_t lastOutput;      // previous output value (for release value calculation)
  bool      pressed;        // if the note is physically pressed
} ADSR;


// ------------ VOICE --------------
#define MAXVOICES   24      // how many voices are allowed to be active at the same time

uint32_t masterVolume = 84; // master volume (scale 0-127)

// Voice data structure
typedef struct {
  ADSR      adsr;           // ADSR values (each voice has its own set of ADSR values)
  uint32_t  wave;           // selected wave (currently unused. only global waveForm variable is used. Should be used when in program mode (adapt midi code to include waveform of note)
  uint32_t  note;           // note ID of voice
  uint32_t  velocity;       // velocity of current note
  uint64_t  indexStep;      // by how much we increase the wave table index for each sample (changes with frequency)
  uint64_t  tableIndex;     // current index of wave table
  int32_t   output;         // integer output of voice, has range of +-2047
  uint32_t  activationTime; // millis when the voice was activated
  uint32_t  volume;         // master volume of voice (above ADSR) (currently unused. only global volume variable is used. Should be used when in program mode (adapt midi code to include waveform of note)
} Voice;

Voice voices[MAXVOICES];    // all voices in one array


//------------- MIDI ---------------
#define MIDICONTROLMAXVAL 127 // maximum value of a MIDI control byte

uint8_t mBuffer[3]  = {0,0,0};  // MIDI argument buffer of three bytes
uint8_t mIdx        = 0;        // current index of MIDI buffer
uint8_t cmdLen      = 2;        // number of arguments of current midi command
uint8_t command     = 0;        // midi command type


//-------------I2S-------------------
#define SAMPLERATE  44100               // samples per second (44.1KHz)
#define SAMPLE_BUFFER_SIZE 64           // size of sample buffer, before sending to I2S driver

uint32_t sampleBuf[SAMPLE_BUFFER_SIZE]; // sample buffer
uint32_t sampleBufIdx = 0;              // current position in sample buffer

//I2S configuration 
#define I2S_PORT (i2s_port_t)0          // i2s port number

i2s_config_t i2s_config = 
{
     .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
     .sample_rate = SAMPLERATE,
     .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
     .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,
     .communication_format = (i2s_comm_format_t)(I2S_COMM_FORMAT_I2S | I2S_COMM_FORMAT_I2S_MSB),
     .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
     .dma_buf_count = 8,
     .dma_buf_len = 128
    };
    
i2s_pin_config_t pin_config = 
{
    .bck_io_num = 26,     // BCK
    .ws_io_num = 25,      // LRCK
    .data_out_num = 32,   // DATA output
    .data_in_num = -1     // Not used
};


/*
 * FUNCTIONS
 */

// What to do when a note is pressed
// Looks for an idle voice slot to assign it to
// If it cannot find an idle slot, it will look for a voice slot with the same note ID 
// If it cannot find slot with the same note ID, it will look for the slot with the lowest amplitude in release state
// If a slot is still not found, it will select the oldest slot
//
// Args:
//  - channel:  MIDI channel of pressed note
//  - noteID:   note ID of pressed note
//  - velocity: velocity of pressed note
void handleNoteOn(uint8_t channel, uint8_t noteID, uint8_t velocity) 
{
  int32_t slot = -1;  // a slot of -1 means that no slot has been selected
  
  // looks for an idle slot
  for (uint32_t n=0; n < MAXVOICES; n++) 
  {
    if(voices[n].adsr.state == ADSR_IDLE)
    {
      slot = n;
      break;
    }
  }

  // if no slot was found, look for a slot with the lowest amplitude in release state
  if (slot == -1) 
  {
    uint32_t lowestRelease = 0xFFFFFFFF; // initialize to max uint32_t value
    for (uint32_t n=0; n < MAXVOICES; n++) 
    {
      // if the voice is in release state
      if(voices[n].adsr.state == ADSR_RELEASE)
      {
        // if the adsr output is lower than the previously found lowest output
        if (voices[n].adsr.output < lowestRelease)
        {
          lowestRelease = voices[n].adsr.output;  // update the lowestRelease
          slot = n;                               // update the current found slot
        }
      }
    }
  }

  // if no slot was found, look for a slot with the same note ID
  // if multiple, select the oldest one
  if (slot == -1) 
  {
    uint32_t lowestTime = 0xFFFFFFFF;
    for (uint32_t n=0; n < MAXVOICES; n++) 
    {
      if (voices[n].note == noteID)
      {
        if (voices[n].activationTime < lowestTime)
        {
          lowestTime = voices[n].activationTime;  // update the lowestTime
          slot = n;                               // update the current found slot
        }
      }
    }
  }

  // if still no slot was found, select the oldest slot
  if (slot == -1) 
  {
    slot = 0;                                   // to make sure slot will always be a valid value
    uint32_t lowestTime = 0xFFFFFFFF;           // initialize to max uint32_t value
    for (uint32_t n=0; n < MAXVOICES; n++) 
    {
      if (voices[n].activationTime < lowestTime)
      {
        lowestTime = voices[n].activationTime;  // update the lowestTime
        slot = n;                               // update the current found slot
      }
    }
  }

  // when we arrive here, we have found a slot
  voices[slot].note = noteID;         // set the note ID
  voices[slot].activationTime = millis();  // set the activation time

  // apply minimum velocity
  if (velocity < 15)
  {
    velocity = 15;
  }
  voices[slot].velocity = velocity;   // set the velocity time
  uint32_t f = getFreq(noteID);       // get freqency of note ID
  setVoiceFreqency(f, slot);          // set the freqency
  setGateOn(slot);                    // notify the ADSR that the note was pressed
}


// What to do when a note is released
// Looks for all voices with the same note ID as the released note ID
// Also checks if the voice is not idle and already in release state, since we want to ignore those
// Then tells the ADSR to release those voices
//
// Args:
//  - channel:  MIDI channel of released note
//  - noteID:   note ID of released note
//  - velocity: velocity of released note
void handleNoteOff(uint8_t channel, uint8_t noteID, uint8_t velocity) 
{
  for (int n=0; n < MAXVOICES; n++) 
  {
    if(voices[n].note == noteID && voices[n].adsr.state != ADSR_IDLE && voices[n].adsr.state != ADSR_RELEASE)
    {
      setGateOff(n);
    }
  }
}


// Returns the current audio sample by doing the following steps:
//  - update the states of the active voices and ADSRs
//  - apply ADSR to the outputs of all active voices
//  - mix those outputs together
//  - scale output to range of DAC
//  - apply clipping where needed
//  - return signed sample
int16_t produceSample() 
{
  // update the states of the active voices and ADSRs
  for (uint32_t n = 0; n < MAXVOICES; n++) 
  {
    if ( voices[n].adsr.state != ADSR_IDLE) 
    {
      updateVoice(n);
      updateADSR(n);  
    }
  }

  // apply ADSR and velocity to the outputs of all active voices and add them together
  int32_t sum = 0;  
  for (uint32_t n = 0; n < MAXVOICES; n++) 
  {
    if (voices[n].adsr.state != ADSR_IDLE) 
    {
      // voice output is in range of +-2047
      // ADSR output is in range of 0-4095
      // multiply both outputs and divide by 4096 to get an output of +-2047
      int32_t signedADSR = voices[n].adsr.output;   // convert uint32_t to int_32t
      int32_t ADSRappliedOutput = (signedADSR * voices[n].output);
      ADSRappliedOutput = ADSRappliedOutput >> 10;
      int32_t VelocityAppliedOutput = (ADSRappliedOutput * voices[n].velocity);
      VelocityAppliedOutput = VelocityAppliedOutput >> 7;
      sum = sum + VelocityAppliedOutput;
    } 
  }

  // apply master volume
  sum = (sum * masterVolume);
  sum = sum >> 7;

  
  // apply hard clipping if needed, and convert to 16 bit
  if (sum > 32767)
    sum = 32767;
  if (sum < -32768)
    sum = -32768;

  int16_t sum16 = sum;
  return sum16;
}



// Things to do at bootup
void setup() 
{
  MidiSerial.begin(115200); // setup serial for MIDI and PC communication

  //initialize i2s
  i2s_driver_install(I2S_PORT, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_PORT, &pin_config);
  //set sample rates of i2s to sample rate of wav file
  i2s_set_sample_rates(I2S_PORT, SAMPLERATE); 
  
  initVoices();
  initADSR();

}


// Things to do when not generating sounds
void loop() 
{
  checkMIDI();        // check for MIDI commands

  // fill buffer with samples
  sampleBufIdx = 0;
  while (sampleBufIdx < SAMPLE_BUFFER_SIZE)
  {
    int16_t sampl = produceSample();
    
    sampleBuf[sampleBufIdx] = (sampl << 16) + sampl; //write sample on both channels, because mono
    sampleBufIdx += 1;
  }

  // send buffer
  i2s_write_bytes(I2S_PORT, (const char *)&sampleBuf[0], sizeof(uint32_t)*SAMPLE_BUFFER_SIZE, 100);

  turnOffLowVolumeNotes();
}
