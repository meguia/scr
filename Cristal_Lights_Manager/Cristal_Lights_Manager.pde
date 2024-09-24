/***
Cristal Lights Manager v.1.0
by Federico Joselevich Puiggrós <f@ludic.cc>
www.ludic.cc

Para uso interno del equipo del LAPSo, UNQ.
***/
import java.net.InetAddress;
import controlP5.*;
import oscP5.*;
import netP5.*;
import java.util.*;

OscP5 oscP5;
NetAddress [] myRemoteLocation = new NetAddress[6];
ControlP5 cp5;
  
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

int brillo = 100;
int timeDelay = 0;
int messageDelay = 300;
int multiplicadorDelay = 0;

Strobo [] strobos = new Strobo[6];
Columna [][] modulos = new Columna[6][20];
float [] rotaciones = new float[6];
boolean sendMessage;
int lastMessage = 0;

color stroboToColor;


void setup() {
  size(1000, 480);

  try {
    InetAddress inetAddress = InetAddress.getLocalHost();
    System.out.println("IP Address:- " + inetAddress.getHostAddress());
    System.out.println("Host Name:- " + inetAddress.getHostName());
    oscP5 = new OscP5(this, 12000);
    columnasMouseChecker = createGraphics(width,height);
    columnasGraphics = createGraphics(width,height);
    println("["+inetAddress.getHostAddress().substring(0,9)+"]");
    for (int i = 0; i < 6; i++) {
       //
      if (inetAddress.getHostAddress().substring(0,9).equals("192.168.0")) {
        myRemoteLocation[i] = new NetAddress("192.168.0.1"+str(i+1), 8000);
        println("Modulo " + i + " : " + "192.168.0.1"+str(i+1));
      } else {
        myRemoteLocation[i] = new NetAddress("127.0.0.1", 8000);
        println("Modulo " + i + " : " + "127.0.0.1");
      }
  	   strobos[i] = new Strobo(i);
       rotaciones[i] = 0;
    }
    initControladores();
    sendMessage = false;
  } catch (Exception e) {
    println(e.toString());
  }  

  stroboToColor = color(0,0,0);
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
  if (sendMessage && millis() > lastMessage + messageDelay) {
    sendMessage = false;
    for (int q = 0; q < modulos.length-1; q++) {
      OscMessage myMessage = new OscMessage("/setColor/"+(q+1)+"/elements/");
      myMessage.add(0);

      for (int i = 0; i < 20; i++) {
          color c = modulos[q][i].c;
          pushStyle();
          colorMode(HSB, 255);
          c = color(hue(modulos[q][i].c), saturation(modulos[q][i].c), min(brightness(modulos[q][i].c),brillo));
          popStyle();

          myMessage.add(red(c));
          myMessage.add(green(c));
          myMessage.add(blue(c));
          myMessage.add(modulos[q][i].t);
      }
      if (multiplicadorDelay > 0) myMessage.add(multiplicadorDelay);
      oscP5.send(myMessage, myRemoteLocation[q]);     
      //println("Enviando " + myMessage + " a " + myRemoteLocation[q]); 
    }
    lastMessage = millis();
    fill(255,0,0);
    ellipse(width-10,10,5,5);
  }
}

////////////////////////////////////////////////////////////////////
///   DRAW /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
void draw() {
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

  if (keyPressed) {
    if (!cp5.get(Textfield.class, "nombre_configuracion").isFocus()) {
      if (key == 'f')  { strobos[0].strobo();  }
    else if (key == 'g')  { strobos[1].strobo();  }
    else if (key == 'h')  { strobos[2].strobo();  }
    else if (key == 'j')  { strobos[3].strobo();  }
    else if (key == 'k')  { strobos[4].strobo();  }
    else if (key == 'l')  { strobos[5].strobo();  }
    }
  }

  pushStyle();
  stroke(255);
  fill(stroboToColor);
  rect(width-90,height-80,40,40);
  popStyle();


  for (int i = 0; i < 6; i++) strobos[i].draw();
  processMessages();


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
    int m = (int)red(colInColumnasChecker)/10;
    int i = (int)green(colInColumnasChecker)/10;
    modulos[m][i].c = w.getRGB();
    println("Modulo: " + m + " Idx: " +i);
  }
}
