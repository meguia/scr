#include <EEPROM.h>
#include <Wire.h>
#include <AccelStepper.h>

#define MAX_LENGTH 7

int SL_ADDR;

byte command[MAX_LENGTH];
byte command_length;
boolean processingMessage = false;
boolean commandComplete = false;

const long MOTOR_STEPS = 200;
const long MICROSTEPS = 16;

const int stepPins[5] = {54, 60, 46, 26, 36};
const int dirPins[5] = {55, 61, 48, 28, 34};
const int enPins[5] = {38, 56, 62, 24, 30};

AccelStepper  stepper1(AccelStepper::DRIVER,  stepPins[0],  dirPins[0]);
AccelStepper  stepper2(AccelStepper::DRIVER,  stepPins[1],  dirPins[1]);
AccelStepper  stepper3(AccelStepper::DRIVER,  stepPins[2],  dirPins[2]);
AccelStepper  stepper4(AccelStepper::DRIVER,  stepPins[3],  dirPins[3]);
AccelStepper  stepper5(AccelStepper::DRIVER,  stepPins[4],  dirPins[4]);

AccelStepper* steppers[] = {
  &stepper1,
  &stepper2,
  &stepper3,
  &stepper4,
  &stepper5,
};

long MAX_VEL = 500; // sin microsteps
long MAX_ACEL = 300;
long MAX_STEP = 1600;
int STEP_ZERO = 128; //Determina el cero del motor (puede cambiarse para hacerse asimetrico)
int STEP_FACTOR = 13; //Conversion de byte (1-255) a FULL STEP con 128 equivalente a 0
int VEL_FACTOR = 4; //Conversion byte a velocidad
int ACEL_FACTOR = 2; // Conversion byte a aceleracion 
#define NMOT  5
boolean isrunning[NMOT]; //array de booleanos que indica si el motor se esta moviendo

void setup()
{
  SL_ADDR = EEPROM.read(0);
  Wire.begin(SL_ADDR);
  Wire.onReceive(receiveEvent); // Registra evento de recibir comando
  Wire.onRequest(requestEvent); // Registra evento de request de posicion
  TWAR = (SL_ADDR << 1) | 1;  // enable broadcasts to be received
  //carga los ultimos valores de posicion velocidad y aceleracion de memoria
  for (int n = 0; n < NMOT; n++) {
    steppers[n]->setCurrentPosition(byte_to_step(EEPROM.read(n+1)));
    steppers[n]->setMaxSpeed(byte_to_vel(128));
    steppers[n]->setAcceleration(byte_to_acel(128));
    steppers[n]->setEnablePin(enPins[n]);
    steppers[n]->setPinsInverted(false, false, true);
    isrunning[n] = false;
  }
  command_length = 0;
}

void loop() {
  if (commandComplete) {
    commandComplete = false;
    processCommand();
  }
  for (int n = 0; n < 5; n++) {
    if (isrunning[n]) {
      steppers[n]->run();
      if (steppers[n]->distanceToGo() == 0) {
        steppers[n]->disableOutputs();
        isrunning[n] = false;
      }
    }
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
  for (byte n = 0; n < numBytes; n++) {
    if (n < MAX_LENGTH)
    {
      tmpcommand[n] = Wire.read();
      command_length++;
    }
    else {
      Wire.read();
    }
  }
  memcpy(command, tmpcommand, MAX_LENGTH);
  commandComplete = true;
  processingMessage = false;
}


long byte_to_step(byte val){
  long steps = constrain((val - STEP_ZERO) * STEP_FACTOR, -MAX_STEP, MAX_STEP);
  return  steps * MICROSTEPS;
}

float byte_to_vel(byte val){
  float vel = constrain(val * VEL_FACTOR, 0 , MAX_VEL);
  return  vel * MICROSTEPS;
}

float byte_to_acel(byte val){
  long acel = constrain(val*ACEL_FACTOR, 0.0, MAX_ACEL);
  return  acel * MICROSTEPS;
}

byte step_to_byte(long step){
  byte b = step/(MICROSTEPS*STEP_FACTOR)+STEP_ZERO;
  return b;
}

byte vel_to_byte(float vel){
  byte b = vel/(MICROSTEPS*VEL_FACTOR);
  return b;
}

byte acel_to_byte(float acel){
  byte b = acel/(MICROSTEPS*ACEL_FACTOR);
  return b;
}

//Devuelve un array de 10 bytes con con las posiciones y los target de todos los motores
void requestEvent() {
  noInterrupts();
  for (int i = 0; i < 5; i++) {
    Wire.write(steppers[i]->currentPosition());
    Wire.write(steppers[i]->distanceToGo());
  }
  interrupts();
}

//Procesa el comando
void processCommand() {
  //registro (opcional)
  byte p_command[MAX_LENGTH];
  memcpy(p_command, command, MAX_LENGTH);
  //byte REG = p_command[0];
  char CMD = p_command[1];
  switch (CMD) {
    //Move to target
    case 's':
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i + 2]) {          
          steppers[i]->enableOutputs();
          isrunning[i] = true;
          steppers[i]->moveTo(byte_to_step(p_command[i+2]));
        }
      }
      break;
    //Enable/Disable motors
    case 'd':
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i + 2]) {          
          steppers[i]->enableOutputs();
        }
        else {
          steppers[i]->disableOutputs();
        }
      }
   
    //Set Position
    case 'z':
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i+2]) {
          steppers[i]->setCurrentPosition(byte_to_step(p_command[i + 2]));
        }
      }
      break;
    //Stop
    case 'p':
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i + 2]) {
          steppers[i]->stop();
          isrunning[i] = false;
        }
      }
      break;   
    //Set max speed
    case 'v':
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i + 2]) {
          steppers[i]->setMaxSpeed(byte_to_vel(p_command[i+2]));
        }
      }
      break;   
    //Set accel
    case 'w': 
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i + 2]) {
          steppers[i]->setAcceleration(byte_to_acel(p_command[i+2]));
        }
      }
      // Save current position and disable outputs '
      break;
      case 'y':
      for (int i = 0; i < NMOT; i++) {
        if (p_command[i + 2]) {
          steppers[i]->stop();
          //save to eeprom
          for (int n = 0; n < NMOT; n++) {
            EEPROM.update(step_to_byte(steppers[n]->currentPosition()),n+1);
          }
        }
      }
      break; 
    default:
      break;
  }
  command_length = 0;
}

