#include <EEPROM.h>
#include <Wire.h>
#include "LED.h"

#define EOM_COMMAND 0x0 // comando de fin de mensaje
int SL_ADDR; // se leerá de la EEPROM
#define MAX_LENGTH 23
LED leds[5];

boolean processingMessage = false;

// shift register:
// Consultar el SwiftPWM_RGB_Simple para más referencia
const int ShiftPWM_latchPin = 8;
const bool ShiftPWM_invertOutputs = false;
const bool ShiftPWM_balanceLoad = false;
#include <ShiftPWM.h>   // include ShiftPWM.h after setting the pins!
unsigned char maxBrightness = 255;
unsigned char pwmFrequency = 75;
int numRegisters = 2;


byte command[MAX_LENGTH];
byte command_length;
boolean commandComplete = false;

int  updateInterval = 5;
unsigned long lastUpdate;
int timeMultiplier = 1;

void setup()
{
  SL_ADDR = EEPROM.read(0);

  Serial.begin(9600);
  Serial.print("Start LED driver at i2c:"); 
  Serial.println(SL_ADDR);
  setupUnusedPINs();
  ShiftPWM.Start(pwmFrequency, maxBrightness);
  ShiftPWM.SetAll(255);
  ShiftPWM.SetAmountOfRegisters(numRegisters);

  // SetPinGrouping allows flexibility in LED setup.
  // If your LED's are connected like this: RRRRGGGGBBBBRRRRGGGGBBBB, use SetPinGrouping(4).
  ShiftPWM.SetPinGrouping(1); //This is the default, but I added here to demonstrate how to use the funtion

  for (int i = 0; i < 5; i++) {
    leds[i].idx = i;
  }

  for (int i = 0; i < 5; i++) {
    ShiftPWM.SetRGB(i,255,255,255);
    delay(100);
  }
  Wire.begin(SL_ADDR);
  TWAR = (SL_ADDR << 1) | 1;  // enable broadcasts to be received
  Wire.onReceive(receiveEvent); // Registra evento de recibir comando
  Wire.onRequest(requestEvent); // Registra evento de request de posicion
  //  Serial.begin(230400);         //Eliminar serial!
  command_length = 0;

  //Serial.println("Cristal LED test started!");
}


void loop() {

  if (commandComplete) {
    commandComplete = false;
    processCommand();
  }
  for (int i = 0; i < 5; i++) {
    leds[i].run();
    // ATENCIÓN... el cableado esta al revés
    ShiftPWM.SetRGB(4-i, leds[i].colors[2], leds[i].colors[1], leds[i].colors[0]);
  }
}

void receiveEvent(int numBytes)
{
  if (processingMessage) {
    unsigned long t = millis();
    while (processingMessage) {
      if (millis() > t + 3000) break;
    }
  }
  
  processingMessage = true;

  byte tmpcommand[MAX_LENGTH];
  //Serial.println("-");
  for (byte n = 0; n < numBytes; n++) {
    tmpcommand[n] = Wire.read();
    //Serial.print(n); Serial.print(": "); Serial.print(tmpcommand[n]); Serial.println(" ");
  }
  memcpy(command,tmpcommand,MAX_LENGTH);
  if (numBytes < 23) command[MAX_LENGTH-1] = 0;

  commandComplete = true;
  processingMessage = false;
}

void requestEvent() {
}


void processCommand() {
  char msg[256];

  // just avoid reading and writing to the same memory address:
  byte processedcommand[MAX_LENGTH];
  memcpy(processedcommand, command, MAX_LENGTH); 
  /*for (int i = 0; i < 23; i++) {
    sprintf(msg, "%i:%3.u ", i, processedcommand[i]);
    Serial.print(msg);
  }
  Serial.println(".");*/
  //sprintf(msg, "cmd: %i l:%i v:%i %i %i %i\n", processedcommand[1], processedcommand[2], processedcommand[3], processedcommand[4], processedcommand[5], processedcommand[6]);
  //Serial.print(msg);
  if (processedcommand[1] == 'M') {
    if (processedcommand[22] > 0) {
      for (int i = 2; i < 5*4; i+=4) {
        leds[(int)(i-2)/4].set(processedcommand[i], processedcommand[i+1], processedcommand[i+2], processedcommand[i+3]);
        //sprintf(msg, " setting: %3.i-%3.i-%3.i in %2.i time %3.i timeMultiplier: %3.u ", processedcommand[i], processedcommand[i+1], processedcommand[i+2], (int)(i-2)/4, processedcommand[i+3], processedcommand[MAX_LENGTH-1]);
        //Serial.println(msg);
        leds[(int)(i-2)/4].timeMultiplier = processedcommand[MAX_LENGTH-1];
      }
      
    } else {
      for (int i = 2; i < 5*4; i+=4) {
        leds[(int)(i-2)/4].set(processedcommand[i], processedcommand[i+1], processedcommand[i+2], processedcommand[i+3]);
        //sprintf(msg, " setting: %3.i-%3.i-%3.i in %3.i time %3.i", processedcommand[i], processedcommand[i+1], processedcommand[i+2], (int)(i-2)/4, processedcommand[i+3]);
        //Serial.println(msg);
        leds[(int)(i-2)/4].timeMultiplier = 10;
      }
    }
    return;
  } else if (processedcommand[1] == 'm') {
    int ledidx = processedcommand[2];
    int r = processedcommand[3];
    int g = processedcommand[4];
    int b = processedcommand[5];
    int t = processedcommand[6];
    //int t = (command[6] << 8) | (command[7]);
    leds[ledidx].set(r,g,b,t);
    //sprintf(msg, " setting: %i-%i-%i in %i time %i", r, g, b, ledidx, t);
    //Serial.println(msg);
    return;
  } else if (processedcommand[1] == 'a') {
    int r = processedcommand[3];
    int g = processedcommand[4];
    int b = processedcommand[5];
    int t = processedcommand[6];
    for (int i = 0; i < 5; i++) {
      leds[i].set(r,g,b,t);
    }
    return;
  } else if (processedcommand[1] == 'b') {
    int t = processedcommand[5*3+5];
    for (int i = 0; i < 5; i++) {
      int r = processedcommand[i*3+3];
      int g = processedcommand[i*3+4];
      int b = processedcommand[i*3+5];
      leds[i].set(r,g,b,t);
    }
  } else if (processedcommand[1] == 'n') {
    // procesa el request
    return;
  } else if (processedcommand[1] == 'o') {
    // procesa el request
    return;
  }  // else if(command[0] == 'n') leds[command[1]].

  //for (int i = 0; i < 5; i++) ShiftPWM.SetRGB(i, leds[i].colors[0], leds[i].colors[1], leds[i].colors[2]);

  leds[command[1]].enUso = false;  
}

void setupUnusedPINs() {
  // Warning: without this code, the LED shield acts noisily...
  int modo = OUTPUT;
  pinMode(0, modo);
  pinMode(1, modo);
  pinMode(2, modo);
  pinMode(3, modo);
  pinMode(4, modo);
  pinMode(5, modo);
  pinMode(6, modo);
  pinMode(7, modo);
  pinMode(9, modo);
  pinMode(10, modo);
  pinMode(12, modo);
  pinMode(A0, modo);
  pinMode(A1, modo);
  pinMode(A2, modo);
  pinMode(A3, modo);
  pinMode(A4, modo);
  pinMode(A5, modo);
  pinMode(A6, modo);
  pinMode(A7, modo);
  
}
