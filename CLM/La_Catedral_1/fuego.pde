class Fuego extends AppBase {
	float offset = 0.0;
	int lastMessage = 0;
	float nivelLuz;
	boolean [] habilitado = new boolean[6];

  public Fuego(PApplet parentApplet, int _id) {
    super(parentApplet,_id);
  }


	@Override public void start() { 
		offset = 0.0;
	    inPlay = true;
    /* Todo lo que se tiene que inicializar cuando empieza la escena */
    	println("Start Fuego");
    	nivelLuz = 1.4;
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
	  offset += 0.1;
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
	          myMessage.add(n*.5);
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
			nivelLuz += .1;
		} else if (keyCode == DOWN) {
			nivelLuz -= .1;
		} else if (key == 'w') habilitado[0] = !habilitado[0];
		 else if (key == 'e') habilitado[1] = !habilitado[1];
		 else if (key == 'r') habilitado[2] = !habilitado[2];
		 else if (key == 't') habilitado[3] = !habilitado[3];
		 else if (key == 'y') habilitado[4] = !habilitado[4];
		 else if (key == 'u') habilitado[5] = !habilitado[5];
		println("nivelLuz: " + nivelLuz);
	}
}


