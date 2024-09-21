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

  void sendLevels() {
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


