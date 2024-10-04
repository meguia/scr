class Laberinto extends AppBase {
  int idx;
  int nextChange;
  public Laberinto(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


  @Override public void start() { 
      inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
      println("Start Laberinto");
      nextChange = 0;
      idx = 0;
  }


  @Override
    public void stop() {
      println("Laberinto stopped...!!");
      inPlay = false;
    }

  @Override
    public void draw() {
    if (millis() > nextChange) {
      nextChange = millis() + 300;
      idx++;
      if (idx > 24) idx = 0;
      for (int q = 0; q < 5; q++) {
        for (int j = 0; j < 20; j++) {
          int n = 0;
          if (idx == q*5+j%5) n = 255;
          modulos[q][j].c = color(n);
          modulos[q][j].t = 1;

        }
      }
      sendMessage = true;
    }
  }
}

/*

class LaberintoOld extends AppBase {
  int cx, cy;
  int [][] mapa = new int[20][5];
  boolean changed = false;
  boolean automatico;
  int moveDelay, nextMove;

  public LaberintoOld(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


  @Override public void start() { 
      inPlay = true;
      println("Start Laberinto");
      cx = 0;
      cy = 0;  
      for (int i=0; i < mapa.length; i++) {
        for (int j=0; j < mapa[0].length; j++) {
          mapa[i][j] = color(0,0, 0);
        }
      }
      moveDelay = 250;
      nextMove = 0;
      automatico = false;
  }

  @Override
    public void stop() {
      println("Laberinto stopped...!!");
      inPlay = false;
    }

  @Override public void idle() {
    println("Idle Laberinto");
  }

  @Override public void draw() {
    println(automatico);
    if (millis() > nextMove || changed) {
      nextMove = millis() + moveDelay;
      if (automatico) movePos();
      for (int i = 0; i < 5; i++) {
        sendMessage(i);
      }
      changed = false;
      fill(0);
      rect(10, 10, 20*20, 5*20);
      fill(255);
      rect(10+cx*10, 10+cy*10, 10, 10);
    }
  fill(255);
  text("a - automatico on/off\nLEFT,RIGHT,UP,DOWN - mover en modo manual", width-210, height-220);
  }

  void sendMessage(int cristalIdx) {
    OscMessage myMessage = new OscMessage("/setColor/");
    myMessage.add(0);
    int lastModulo = -1;
    for (int i = cristalIdx*4; i < cristalIdx*4+4; i++) {
      for (int j = 0; j < mapa[0].length; j++) {
        myMessage.add((int)blue(mapa[i][j]));
        myMessage.add((int)green(mapa[i][j]));
        myMessage.add((int)red(mapa[i][j]));
        myMessage.add(30);
      }
    }
    sendOSCMessage(myMessage, myRemoteLocation[cristalIdx], false);
  }

  void movePos() {
    mapa[cx][cy] = color(0, 0, 0);
    float r = random(1);
    if (r > .66) cx += (random(1) > .5)?1:-1;
    else if (r > .33) cy += (random(1) > .5)?1:-1;
    if (cx < 0) cx = 19;
    if (cx > 19) cx = 0;
    if (cy < 0) cy = 4;
    if (cy > 4) cy = 0;
    mapa[cx][cy] = color(255, 255, 255);
    changed = true;
  }



  @Override public 
  void keyPressed() {
    mapa[cx][cy] = color(0, 0, 0);
    if (keyCode == LEFT) {
      cx--;
      if (cx < 0) cx = 19;
    } else if (keyCode==RIGHT) {
      cx++;
      if (cx > 19) cx = 0;
    } else if (keyCode == UP) {
      cy--;
      if (cy < 0) cy = 4;
    } else if (keyCode==DOWN) {
      cy++;
      if (cy > 4) cy = 0;
    } else if (key == 'a') automatico = !automatico;
    mapa[cx][cy] = color(128, 128, 128);
    changed = true;
  }

}
*/

