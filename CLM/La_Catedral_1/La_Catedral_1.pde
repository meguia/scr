import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress [] myRemoteLocation = new NetAddress[6];

ArrayList<AppBase> escenas;
int escena = -1;
int initLevel = 0;
int nextescena = -3;

int INTRO = 0x0;
int LABERINTO = 0x1;
int CASINO = 0x2;
int FUEGO = 0x3;
int CONTRAPUNTO = 0x4;

Strobo [] strobos = new Strobo[6];

void setup() {
  size(640, 480);
  oscP5 = new OscP5(this, 12000);

  for (int i = 0; i < 6; i++) {
    myRemoteLocation[i] = new NetAddress("192.168.0.1"+str(i+1), 8000);
	strobos[i] = new Strobo(i);
  }
}


void doInit() {
  //creating an instance of our list
  escenas = new ArrayList<AppBase>();
  escenas.add(new Intro(this, INTRO));
  escenas.add(new Laberinto(this, LABERINTO));
  escenas.add(new Casino(this, CASINO));
  escenas.add(new Fuego(this, FUEGO));
  escenas.add(new Contrapunto(this, CONTRAPUNTO));

}

void draw() {
  if (initLevel > 1) {
  } else if (initLevel == 1) {
    doInit();
    initLevel++;
  } else if (initLevel == 0) {
    background(0);
    initLevel++;
    return;
  }


  if (nextescena > -3) {
    doSetEscena(nextescena);
    nextescena = -3;
  }

  pushStyle();
  if (escena > -1) {
    for (int i = 0; i < escenas.size (); i++) {
      if (escenas.get(i).inPlay) {
        //println("Playing escena " + i);
        escenas.get(i).idle();
        escenas.get(i).draw();
      }
    }
  }
  fill(255);
  text("1 - Intro\n2 - Laberinto\n3 - Contrapunto\n4 - Casino\n5 - Fuego\nf a l - strobos(mod 1 a 6)", 10, height-120);
  popStyle();
  for (int i = 0; i < 6; i++) strobos[i].draw();

}

void keyPressed() {
  if (initLevel < 2) return;
       if (key == '1')  { setEscena(INTRO); }
  else if (key == '2')  { setEscena(LABERINTO); }
  else if (key == '3')  { setEscena(CONTRAPUNTO); }
  else if (key == '4')  { setEscena(CASINO); }
  else if (key == '5')  { setEscena(FUEGO); }
  else if (key == 'f')  { strobos[0].strobo();  }
  else if (key == 'g')  { strobos[1].strobo();  }
  else if (key == 'h')  { strobos[2].strobo();  }
  else if (key == 'j')  { strobos[3].strobo();  }
  else if (key == 'k')  { strobos[4].strobo();  }
  else if (key == 'l')  { strobos[5].strobo();  }
  else if (key == ' ')  { sendStop(); }
  else {
    if (escena > -1) {
      for (int i = 0; i < escenas.size (); i++) {
        if (escenas.get(i).inPlay) {
          escenas.get(i).keyPressed();
        }
      }
    }
  }
  
}

void sendStop() {
	if (escena > -3) closeEscena(escena);
    OscMessage myMessage = new OscMessage("/stopLeds/");
    myMessage.add(0);
    for (int i = 0; i < 20; i++) myMessage.add(0);
    for (int q = 0; q < 5; q++) {
	      oscP5.send(myMessage, myRemoteLocation[q]);
	 }
}