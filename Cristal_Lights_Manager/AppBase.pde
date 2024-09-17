public abstract class AppBase
{  
  public int id;
  public boolean inPlay = false;
  public boolean selfstop = false;
  public boolean stopother = true;
  public PApplet parent;
  public AppBase(PApplet parentApplet, int _id) {
    parent = parentApplet;
    id = _id;
    stopother = true;
  }
  
  public void setup() {};
  public void idle() {}; 
  public void draw() {};
  public void start() {}; 
  public void stop() {}; 
  public void softstop() { stop(); }; 
  public void keyPressed() {};
  public void keyReleased() {};
  public void mousePressed() {};
  public void mouseReleased() {}
  public void mouseMoved() {}
  public void learnConfiguration(int mx, int my) {};
  public void grabarConfiguracion() {};
  public void accion() {};
  public void loadConfig() {};
  public void controllerChange(int num, int val) {};
}


class EscenaEjemplo extends AppBase
{

  int variable_0;

  public EscenaEjemplo(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }

  @Override
    public void setup() {
      println("Setup EscenaEjemplo");
    noSmooth();
  }

  @Override
    public void start() {
      /* Todo lo que se tiene que inicializar cuando empieza la escena */
      inPlay = true;
  }

  @Override
    public void stop() {
      inPlay = false;

}

  @Override
    public void keyPressed() {
    if (key == ' ') {
    } 
  }

  @Override
    public void draw() {

  }
};
