#define ADDR 0x05
#include "EEPROM.h"
void setup() {
  Serial.begin(9600);
  EEPROM.update(0, ADDR);
  Serial.print(ADDR);
  Serial.println(" stored at EEPROM address 0: ");
  Serial.write(EEPROM.read(0));
}

void loop() {}
