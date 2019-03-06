#ifndef LED_h
#define MyClass_h

#include <Arduino.h>

#define CRED    0
#define CGREEN  1
#define CBLUE   2

class LED {
  public:
    LED();
    int colors[3];
    int destcolors[3];
    int oricolors[3];
    unsigned long finalTime, startTime;
    boolean enUso;
    int idx;

    void changeIndividual(byte color, int value);
    void setIndividual(byte color, int value);
    void set(int dr, int dg, int db, int dtime);

    void run();
};

#endif
