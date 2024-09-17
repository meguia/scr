import controlP5.*;
import oscP5.*;
import netP5.*;
import java.util.*;

OscP5 oscP5;
NetAddress [] myRemoteLocation = new NetAddress[6];
ControlP5 cp5;
String[] filenames;

  
PGraphics columnasMouseChecker,columnasGraphics;

ArrayList<AppBase> escenas;
int escena = -1;
int initLevel = 0;
int nextescena = -3;

int INTRO = 0x0;
int LABERINTO = 0x1;
int CASINO = 0x2;
int FUEGO = 0x3;
int CONTRAPUNTO = 0x4;

int MESSAGE_DELAY = 300;

Strobo [] strobos = new Strobo[6];
Columna [][] modulos = new Columna[6][20];
float [] rotaciones = new float[6];
boolean sendMessage;
int lastMessage = 0;


void setup() {
  size(1000, 480);
  oscP5 = new OscP5(this, 12000);
  columnasMouseChecker = createGraphics(width,height);
  columnasGraphics = createGraphics(width,height);

  for (int i = 0; i < 6; i++) {
     //myRemoteLocation[i] = new NetAddress("127.0.0.1", 8000);
     myRemoteLocation[i] = new NetAddress("192.168.0.1"+str(i+1), 8000);
	   strobos[i] = new Strobo(i);
     rotaciones[i] = 0;
  }
  initControladores();
  sendMessage = false;
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

void processMessages() {
  if (sendMessage && millis() > lastMessage + MESSAGE_DELAY) {
    sendMessage = false;
    for (int q = 0; q < modulos.length; q++) {
      OscMessage myMessage = new OscMessage("/setColor/"+(q+1)+"/elements/");
      myMessage.add(0);

      for (int i = 0; i < 20; i++) {
          myMessage.add(red(modulos[q][i].c));
          myMessage.add(green(modulos[q][i].c));
          myMessage.add(blue(modulos[q][i].c));
          myMessage.add(0);
      }
      oscP5.send(myMessage, myRemoteLocation[q]);     
      println("Enviando " + myMessage + " a " + myRemoteLocation[q]); 
    }
    lastMessage = millis();
  }
}

////////////////////////////////////////////////////////////////////
///   DRAW /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
void draw() {
  processMessages();
  background(0);
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
  popStyle();

  drawModulos();

  for (int i = 0; i < 6; i++) strobos[i].draw();

}

void keyPressed() {
  if (initLevel < 2) return;
  if (cp5.get(Textfield.class, "nombre_configuracion").isFocus()) return;
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
    for (int q = 0; q < 6; q++) {
	      oscP5.send(myMessage, myRemoteLocation[q]);
	 }
}

void mousePressed() {
  color colInColumnasChecker = columnasMouseChecker.get(mouseX,mouseY);
  //println(colInColumnasChecker + " " + red(colInColumnasChecker) + " " + green(colInColumnasChecker) + " " + blue(colInColumnasChecker));
  if (blue(colInColumnasChecker) == 255) {
    ColorWheel w = (ColorWheel)cp5.get("colorWheel");
    modulos[(int)red(colInColumnasChecker)/10][(int)green(colInColumnasChecker)/10].c = w.getRGB();
  }
}