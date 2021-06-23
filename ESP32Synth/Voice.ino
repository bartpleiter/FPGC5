/*
 * VOICE
 * Contains all voice related functions
 */


// Initialize all voices
void initVoices() 
{
  for (uint32_t n = 0; n < MAXVOICES; n++) 
  {
    voices[n].activationTime  = 0;
    voices[n].indexStep       = 0;
    voices[n].tableIndex      = 0;
    voices[n].adsr.state      = ADSR_IDLE;
    voices[n].adsr.output     = 0;
  }
}


// Set frequency of voice n by setting the index step based on the given frequency
// Index step is multiplied by 256 to preserve precision
void setVoiceFreqency(uint32_t f, uint32_t n) 
{
  voices[n].indexStep = WAVETABLELENGTH  * f; 
  voices[n].indexStep = voices[n].indexStep << 10;   // multiply by 1024 to prevent losing precision
  voices[n].indexStep = voices[n].indexStep / SAMPLERATE;
  voices[n].tableIndex = 0;
}


// Updates the state of the voice by incrementing counters and traversing trough the wave tables
void updateVoice(uint32_t n) 
{
  // step through the wavetable, the larger the step value, the higher the frequency
  voices[n].tableIndex += voices[n].indexStep;  

  // we divide here by 1024, since the index step is multiplied by 1024 (for precision)
  uint32_t tIdx = (voices[n].tableIndex >> 10);
  tIdx = tIdx % WAVETABLELENGTH; // wrap around the table bounds

  int32_t amplitude = 0;
  // which table to use:
  if(waveForm == SAW)
    amplitude = getSawInt(tIdx);
  else if(waveForm == SIN)
    amplitude = getSinInt(tIdx);  
  else if(waveForm == TRI)
    amplitude = getTriInt(tIdx); 
  else if(waveForm == SQR)
    amplitude = (tIdx < pwmWidth)?-2047:2047; 

  // set output value
  voices[n].output = amplitude; //  +- 2047
}
