import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class La_Catedral_1 extends PApplet {




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

public void setup() {
  
  oscP5 = new OscP5(this, 12000);

  for (int i = 0; i < 6; i++) {
    myRemoteLocation[i] = new NetAddress("192.168.0.1"+str(i+1), 8000);
	strobos[i] = new Strobo(i);
  }
}


public void doInit() {
  //creating an instance of our list
  escenas = new ArrayList<AppBase>();
  escenas.add(new Intro(this, INTRO));
  escenas.add(new Laberinto(this, LABERINTO));
  escenas.add(new Casino(this, CASINO));
  escenas.add(new Fuego(this, FUEGO));
  escenas.add(new Contrapunto(this, CONTRAPUNTO));

}

public void draw() {
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

public void keyPressed() {
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

public void sendStop() {
	if (escena > -3) closeEscena(escena);
    OscMessage myMessage = new OscMessage("/stopLeds/");
    myMessage.add(0);
    for (int i = 0; i < 20; i++) myMessage.add(0);
    for (int q = 0; q < 5; q++) {
	      oscP5.send(myMessage, myRemoteLocation[q]);
	 }
}
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
class Casino extends AppBase {
	int lastMessage = 0;
	int nextMessageDelay;
	Ruleta ruleta = new Ruleta();
	Secuencia secuencia0;
	int upperLevelRandom;
	boolean [] habilitado = new boolean[6];


  public Casino(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
    secuencia0 = new Secuencia();
    /*secuencia0.secuencias.add( { {0, 1, 0, 1, 0 }, 
    							 {1, 0, 1, 0, 1 }, 
    							 {0, 1, 0, 1, 0 }, 
    							 {1, 0, 1, 0, 1 }, 
    							 {0, 1, 0, 1, 0 } }
    	);*/

    secuencia0.secuencias.add( new int[][]{  {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 } }
			    	);
    secuencia0.secuencias.add( new int[][]{ {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 1, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 } }
			    	);
    secuencia0.secuencias.add( new int[][]{ {0, 0, 0, 0, 0 }, 
			    							 {0, 0, 1, 0, 0 }, 
			    							 {0, 1, 1, 1, 0 }, 
			    							 {0, 0, 1, 0, 0 }, 
			    							 {0, 0, 0, 0, 0 } }
			    	);
    secuencia0.secuencias.add( new int[][]{ {0, 0, 1, 0, 0 }, 
			    							 {0, 1, 1, 1, 0 }, 
			    							 {1, 1, 0, 1, 1 }, 
			    							 {0, 1, 1, 1, 0 }, 
			    							 {0, 0, 1, 0, 0 } }
			    	);
    secuencia0.secuencias.add( new int[][]{ {0, 1, 1, 1, 0 }, 
			    							 {1, 0, 0, 0, 1 }, 
			    							 {1, 0, 0, 0, 1 }, 
			    							 {1, 0, 0, 0, 1 }, 
			    							 {0, 1, 1, 1, 0 } }
			    	);
    secuencia0.secuencias.add( new int[][]{ {1, 1, 0, 1, 1 }, 
			    							 {1, 0, 0, 0, 1 }, 
			    							 {0, 0, 0, 0, 0 }, 
			    							 {1, 0, 0, 0, 1 }, 
			    							 {1, 1, 0, 1, 1 } }
			    	);
    
  }


	@Override public void start() { 
	    inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
    	println("Start Casino");
    	nextMessageDelay = 250;
    	upperLevelRandom = 12;
    	for (int i = 0; i < 6; i++) habilitado[i] = true;
  }

  @Override
    public void stop() {
      println("Casino stopped...!");
    	inPlay = false;
	  }

	@Override public void draw() {
	  if (lastMessage < millis() - nextMessageDelay) {
	  	background(0);
	  	//nextMessageDelay += 50;
		ruleta.idle();
		secuencia0.idle();
	    for (int q = 0; q < 5; q++) {
		    OscMessage myMessage = new OscMessage("/setColor/0/elements/");
		    myMessage.add(0);
	        for (int j = 0; j < 4; j++) {
		      for (int i = 0; i < 5; i++) {
			      	int n = 0; 
			      	/*
		      		if (q == 4) n  = ruleta.valores[j][i];
		      		else if (q == 3) {
		      			n = secuencia0.secuencias.get(secuencia0.pos)[j][i]*255;
		      		}
		      		*/
		      		//n = secuencia0.secuencias.get(secuencia0.pos)[j][i]*255;
		      		if (!habilitado[q]) {
		      			myMessage.add(0);
		      			myMessage.add(0);
		      			myMessage.add(0);
		      			myMessage.add(0);
		      		} else {
			      		if (q == 0 || q == 4) n  = ruleta.valores[j][i];
			      		else n = secuencia0.secuencias.get(secuencia0.pos)[j][i];
			      		if (n == 1) {
							fill (n*255);
							rect(j*20+5+q*5*20, i*20+5, 20, 20);
							myMessage.add(n*255);
							myMessage.add(n*255);
							myMessage.add(n*255);
							myMessage.add(10);
						} else {
							int r = (int)random(upperLevelRandom);
							int g = (int)random(upperLevelRandom);
							int b = (int)random(upperLevelRandom);
							myMessage.add(r);
							myMessage.add(g);
							myMessage.add(b);
							myMessage.add(10);
							fill (r*10,g*10,b*10);
							rect(j*20+5+q*5*20, i*20+5, 20, 20);
						}
					}
				}
	      }
	      oscP5.send(myMessage, myRemoteLocation[q]);
	    }
	    lastMessage = millis();
	  }		
	}

	@Override public void keyPressed() {
		if (!inPlay) return;
		if (keyCode == UP) {
			upperLevelRandom++;
			upperLevelRandom = min(255, max(0, upperLevelRandom));
			println(upperLevelRandom);
		} else if (keyCode == DOWN) {
			upperLevelRandom--;
			upperLevelRandom = min(255, max(0, upperLevelRandom));
			println(upperLevelRandom);
		} else if (keyCode == LEFT) {
			nextMessageDelay = constrain(nextMessageDelay-10,200,600);
			println("nextMessageDelay:"+nextMessageDelay);
		} else if (keyCode == UP) {
			nextMessageDelay = constrain(nextMessageDelay+10,200,600);
			println("nextMessageDelay:"+nextMessageDelay);

		} else if (key == 'w') habilitado[0] = !habilitado[0];
		 else if (key == 'e') habilitado[1] = !habilitado[1];
		 else if (key == 'r') habilitado[2] = !habilitado[2];
		 else if (key == 't') habilitado[3] = !habilitado[3];
		 else if (key == 'y') habilitado[4] = !habilitado[4];
		 else if (key == 'u') habilitado[5] = !habilitado[5];
	}
}


class Ruleta {
	int [][] valores = new int[4][5];
	int pos;
	int [] secuencia = { 0, 1, 2, 3, 4, 9, 14, 19, 18, 17, 16, 15, 10, 5 };

	Ruleta() {
		resetValues();
		pos = 0;
	}

	public void idle() {
		resetValues();
		pos++;
		if (pos > secuencia.length-1) pos = 0;
		valores[(int)secuencia[pos]/5][(int)secuencia[pos]%5] = 1;
	}

	public void resetValues() {
		for (int i = 0; i < valores.length; i++)
			for (int j = 0; j < valores[0].length; j++)
				valores[i][j] = 0;
	}	
}

class Secuencia {
	ArrayList <int [][]> secuencias;
	int pos;
	int delayBetweenSequences;
	int lastSequence;

	Secuencia() {
		secuencias = new ArrayList();
		delayBetweenSequences = 120;
		lastSequence = 0;
	}

	public void idle() {
		if (secuencias.size() == 0) return;
		if (millis() > lastSequence + delayBetweenSequences) {
			pos++;
			if (pos > secuencias.size()-1) pos = 0;
			lastSequence = millis();
		}
	}


}
class Contrapunto extends AppBase {
  int modulo;
  public Contrapunto(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


	@Override public void start() { 
	    inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
    	println("Start Contrapunto");
    	modulo = 0;
 	
  }

  @Override
    public void stop() {
      println("Contrapunto stopped...!");
    	inPlay = false;
	  }

	@Override public void draw() {
	    background(0);		
	    for (int q = 0; q < 5; q++) {
	    	if (q+1==modulo) fill(128);
	    	else fill(0);
	        for (int j = 0; j < 4; j++) {
		      for (int i = 0; i < 5; i++) {
					rect(j*20+5+q*5*20, i*20+5, 20, 20);
				}
			}
		}

	}

	@Override public void keyPressed() {
		if (key == 'q') modulo = 0;
		else if (key == 'w') modulo = 1;
		else if (key == 'e') modulo = 2;
		else if (key == 'r') modulo = 3;
		else if (key == 't') modulo = 4;
		else if (key == 'y') modulo = 5;
		showModulo();
	}

	public void showModulo() {
	    for (int q = 0; q < 5; q++) {
		    OscMessage myMessage = new OscMessage("/setColor/0/elements/");
		    myMessage.add(0);
			for (int i = 0; i < 5; i++) {
				for (int j = 0; j < 4; j++) {
					float n = 0;
					if (modulo == q+1) n = 128;
					myMessage.add(n);
					myMessage.add(n);
					myMessage.add(n);
					myMessage.add(0);
				}
			}
			oscP5.send(myMessage, myRemoteLocation[q]);
	    }   		
	}

}


class Fuego extends AppBase {
	float offset = 0.0f;
	int lastMessage = 0;
	float nivelLuz;
	boolean [] habilitado = new boolean[6];

  public Fuego(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


	@Override public void start() { 
		offset = 0.0f;
	    inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
    	println("Start Fuego");
    	nivelLuz = 1.4f;
    	habilitado[0] = true;
    	habilitado[1] = true;
    	habilitado[2] = true;
    	habilitado[3] = true;
    	habilitado[4] = true;
    	habilitado[5] = false;
  }

  @Override
    public void stop() {
      println("Fuego stopped...!");
    	inPlay = false;
	  }

	@Override public void draw() {
	  offset += 0.1f;
	  if (lastMessage < millis() - 150) {
	    for (int q = 0; q < 6; q++) {
		    OscMessage myMessage = new OscMessage("/setColor/0/elements/");
		    myMessage.add(0);
	      for (int i = 0; i < 5; i++) {
	        for (int j = 0; j < 4; j++) {
	          float n = noise(i+offset, j+offset+q*5);
	          if (q == 0 || q == 2) n *= 128;
	          else if (q == 1 || q == 3) n *= 32;
	          else n*= 16;
	          n = (int)((float)n*nivelLuz);
	          myMessage.add(n);
	          myMessage.add(n*.5f);
	          myMessage.add(0);
	          myMessage.add(10);

	          fill(n*1, 0, n);
	          rect(j*20+5+q*5*20, i*20+5, 20, 20);
	        }
	      }
	      oscP5.send(myMessage, myRemoteLocation[q]);
	    }
	    lastMessage = millis();
	  }		
	}
@Override public void keyPressed() {
		if (!inPlay) return;
		if (keyCode == UP) {
			nivelLuz += .1f;
		} else if (keyCode == DOWN) {
			nivelLuz -= .1f;
		} else if (key == 'w') habilitado[0] = !habilitado[0];
		 else if (key == 'e') habilitado[1] = !habilitado[1];
		 else if (key == 'r') habilitado[2] = !habilitado[2];
		 else if (key == 't') habilitado[3] = !habilitado[3];
		 else if (key == 'y') habilitado[4] = !habilitado[4];
		 else if (key == 'u') habilitado[5] = !habilitado[5];
		println("nivelLuz: " + nivelLuz);
	}
}


JSONArray configuracion;

public void loadDefaults() {
  try {
    configuracion = loadJSONArray("data/configuracion.json");
  } 
  catch (Exception e) {
    println("Error cargando los defaults: " + e.toString());
  }
}

public JSONObject getConfiguracionEscena(int id) { // -1 para general, 0 en adelante para las escenas...
  loadDefaults();
  println("Cargando configuración para la escena " + id);
  
  for (int i = 0; i < configuracion.size(); i++) {
    JSONObject config = configuracion.getJSONObject(i); 
    if (config != null && config.getInt("id") == id) return configuracion.getJSONObject(i);
  }
  println("Atención! No se encontró la configuración de "+id);
  throw new java.lang.RuntimeException();
}

public void setConfiguracionEscena(int id, JSONObject configuracion_particular) {
  println("Guardando configuración para "+id+":"+configuracion_particular);

  if (configuracion_particular == null) {
    throw new java.lang.RuntimeException();
  }
  
  boolean found = false;
  for (int i = 0; i < configuracion.size(); i++) {
    JSONObject config = configuracion.getJSONObject(i); 
    if (config != null && config.getInt("id") == id) {
      configuracion.setJSONObject(i, configuracion_particular);
      found = true;
      break;
    }
  }
  if (!found) {
    configuracion.setJSONObject(configuracion.size(), configuracion_particular);
  }
  
  println(configuracion.toString());
  saveJSONArray(configuracion, "data/configuracion.json");
}

public void resetEscenas() {
  for (int i = 0; i < escenas.size (); i++) escenas.get(i).setup();
}

public AppBase getEscena(int nescena) {
  for (int i = 0; i < escenas.size (); i++) {
    if (escenas.get(i).id == nescena) {
      return escenas.get(i);
    }
  }
  return null;
}

// si está encendida la apagamos, si está apagada la encendemos
public void switchEscena(int nescena) {
  // 
  // Buscamos cual de todas las escenas tiene ese ID.
  int idx = -1;
  for (int i = 0; i < escenas.size (); i++) {
    if (escenas.get(i).id == nescena) {
      idx = i;
      break;
    }
  }

  if (idx > -1) {
    if (escenas.get(idx).inPlay) escenas.get(idx).softstop();
    else setEscena(nescena); //nextescena = idx;
  } else {
    println("Error, no se encontró la escena! " + nescena);
  }
}

public void setEscena(int nescena) {
  // Buscamos cual de todas las escenas tiene ese ID.
  int idx = -1;
  for (int i = 0; i < escenas.size (); i++) {
    if (escenas.get(i).id == nescena) {
      idx = i;
      break;
    }
  }

  if (idx > -1) {
    println("Poniendo en cola escena: " + nescena + " indice: " + idx);
    nextescena = idx;
  } else {
    println("Error, no se encontró la escena! " + nescena);
  }
}

public void closeEscena(int nescena) {
  // Buscamos cual de todas las escenas tiene ese ID.
  int idx = -1;
  for (int i = 0; i < escenas.size (); i++) {
    if (escenas.get(i).id == nescena) {
      idx = i;
      break;
    }
  }

  if (idx > -1) {
    println("Cerrando escena: " + nescena + " indice: " + idx);
    escenas.get(idx).stop();
  } else {
    println("Error, no se encontró la escena! " + nescena);
  }
}



public void doSetEscena(int idescena) {
  if (escenas.get(idescena).stopother) {
    for (int i = 0; i < escenas.size(); i++) {
      if (escenas.get(i).inPlay && !escenas.get(i).selfstop) {
        escenas.get(i).stop();
      }
    }
  }
  escena = idescena;
  println("A punto de iniciar la escena: " + escena);
  escenas.get(escena).start();
}
class Intro extends AppBase {
	int whiteLevel;
	boolean [] habilitado = new boolean[6];

  public Intro(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


	@Override public void start() { 
	    inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
    	println("Start Intro");
    	sendLevels();
    	whiteLevel = 0;
    	habilitado[0] = true;
    	habilitado[1] = true;
    	habilitado[2] = true;
    	habilitado[3] = true;
    	habilitado[4] = true;
    	habilitado[5] = false;
  }

  public void sendLevels() {
	    for (int q = 0; q < 6; q++) {
	    OscMessage myMessage = new OscMessage("/setColor/0/elements/");
	    myMessage.add(0);
	      for (int i = 0; i < 5; i++) {
	        for (int j = 0; j < 4; j++) {
	        	int n;
	      		if (habilitado[q]) n = whiteLevel;
	      		else n = 0;
	          myMessage.add(n);
	          myMessage.add(n);
	          myMessage.add(n);
	          myMessage.add(100);
	        }
	      }
	      oscP5.send(myMessage, myRemoteLocation[q]);
	    }    	
  }

  @Override
    public void stop() {
      println("Intro stopped...!");
    	inPlay = false;
	  }

	@Override public void draw() {
		background(0);
	    for (int q = 0; q < 5; q++) {
	        for (int j = 0; j < 4; j++) {
		      for (int i = 0; i < 5; i++) {
		      		if (habilitado[q]) fill (whiteLevel*2);
		      		else fill(0);
					rect(j*20+5+q*5*20, i*20+5, 20, 20);
				}
			}
		}
	  fill(255);
	  text("Intro / Todos los módulos\nen blanco controlable\nUP - Subir blanco\nDOWN - Bajar blanco", width-210, height-220);

	}
	@Override public void keyPressed() {
		if (!inPlay) return;
		if (keyCode == UP) {
			whiteLevel++;
			whiteLevel = min(255, max(0, whiteLevel));
			println(whiteLevel);
		} else if (keyCode == DOWN) {
			whiteLevel--;
			whiteLevel = min(255, max(0, whiteLevel));
			println(whiteLevel);
		} else if (key == 'w') habilitado[0] = !habilitado[0];
		 else if (key == 'e') habilitado[1] = !habilitado[1];
		 else if (key == 'r') habilitado[2] = !habilitado[2];
		 else if (key == 't') habilitado[3] = !habilitado[3];
		 else if (key == 'y') habilitado[4] = !habilitado[4];
		 else if (key == 'u') habilitado[5] = !habilitado[5];
		sendLevels();
	}	
}


class Laberinto extends AppBase {
  int cx, cy;
  int [][] mapa = new int[20][5];
  boolean changed = false;
  boolean automatico;
  int moveDelay, nextMove;

  public Laberinto(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


  @Override public void start() { 
      inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
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
      automatico = true;
  }

  @Override
    public void stop() {
      println("Laberinto stopped...!");
      inPlay = false;
    }

  @Override public void draw() {
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

  public void sendMessage(int cristalIdx) {
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
    oscP5.send(myMessage, myRemoteLocation[cristalIdx]);
  }

  public void movePos() {
    mapa[cx][cy] = color(0, 0, 0);
    float r = random(1);
    if (r > .66f) cx += (random(1) > .5f)?1:-1;
    else if (r > .33f) cy += (random(1) > .5f)?1:-1;
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


class Strobo {
	int final_strobo;
	boolean inUse;
	int cristalIdx;

	Strobo(int idx) {
		cristalIdx = idx;
		inUse = false;
	}

	public void strobo() {
		//if (cristalIdx < 1 || cristalIdx > 6) return;

	    OscMessage myMessage = new OscMessage("/setColor/");
	    myMessage.add(0);

	    for (int i = 0; i < 20; i++) {
	        myMessage.add(255);
	        myMessage.add(255);
	        myMessage.add(255);
	        myMessage.add(0);
	    }
	    oscP5.send(myMessage, myRemoteLocation[cristalIdx]);
	    inUse = true;
	    final_strobo = millis() + 20;
	}

	public void draw() {
		if (inUse && millis() > final_strobo) {
		    OscMessage myMessage = new OscMessage("/setColor/");
		    myMessage.add(0);

		    for (int i = 0; i < 20; i++) {
		        myMessage.add(0);
		        myMessage.add(0);
		        myMessage.add(0);
		        myMessage.add(0);
		    }
		    oscP5.send(myMessage, myRemoteLocation[cristalIdx]);
		    inUse = false;

		}
	}
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#000000", "--hide-stop", "La_Catedral_1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
