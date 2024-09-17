#include "LED.h"

LED::LED() {
  for (int i = 0; i < 3; i++) {
    colors[i] = 0;
  }
  memcpy(oricolors, colors, sizeof(int)*3);
  memcpy(destcolors, colors, sizeof(int)*3);
  finalTime = 0;
  startTime = 0;
  timeMultiplier = 1;
}

void LED::set(int dr, int dg, int db, int dtime) {
  memcpy(oricolors, colors, sizeof(int)*3);
  destcolors[0] = dr;
  destcolors[1] = dg;
  destcolors[2] = db;
  finalTime = millis() + dtime*timeMultiplier;
  startTime = millis();
  //char msg[256];
  //sprintf(msg, "setting led %i to r:%i g:%i b:%i in %i millis", idx, dr, dg, db, dtime);
}

void LED::run() {
  if (finalTime > millis()) {
    for (int i = 0; i < 3; i++) {
      colors[i] = map(millis(), startTime, finalTime, oricolors[i], destcolors[i]);
    }
  } else {
    memcpy(colors, destcolors, sizeof(int)*3);
  }
}
