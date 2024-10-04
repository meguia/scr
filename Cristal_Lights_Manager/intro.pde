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
    	sendMessage = true;
    	whiteLevel = 0;
    	habilitado[0] = true;
    	habilitado[1] = true;
    	habilitado[2] = true;
    	habilitado[3] = true;
    	habilitado[4] = true;
    	habilitado[5] = false;
		cp5.getController("intro").setVisible(true);
  }

  void sendLevels() {
		ColorWheel w = (ColorWheel)cp5.get("colorWheel");
		color col = w.getRGB();
		pushStyle();
		colorMode(HSB,255);
		col = color(hue(col),saturation(col),min(whiteLevel,brightness(col)));
		popStyle();
	    for (int q = 0; q < 5; q++) {
	      for (int i = 0; i < 5; i++) {
	        for (int j = 0; j < 4; j++) {
	        	int n;
	      		if (habilitado[q]) modulos[q][i*4+j].c  = col;
	      		else modulos[q][i*4+j].c = color(0);
	      		modulos[q][i*4+j].t = 20;
	        }
	      }
	    }    	
	    sendMessage = true;
  }

  @Override
    public void stop() {
		cp5.getController("intro").setVisible(false);
      println("Intro stopped...!");
    	inPlay = false;
	  }

	@Override public void draw() {

	}
	@Override public void keyPressed() {
		if (!inPlay) return;
		if (keyCode == UP) {
			whiteLevel++;
			whiteLevel = min(255, max(0, whiteLevel));
			println(whiteLevel);
			sendLevels();
			cp5.getController("intro").setValue(whiteLevel);
		} else if (keyCode == DOWN) {
			whiteLevel--;
			whiteLevel = min(255, max(0, whiteLevel));
			println(whiteLevel);
			sendLevels();
			cp5.getController("intro").setValue(whiteLevel);
		} else if (key == 'w') habilitado[0] = !habilitado[0];
		 else if (key == 'e') habilitado[1] = !habilitado[1];
		 else if (key == 'r') habilitado[2] = !habilitado[2];
		 else if (key == 't') habilitado[3] = !habilitado[3];
		 else if (key == 'y') habilitado[4] = !habilitado[4];
		 else if (key == 'u') habilitado[5] = !habilitado[5];
		
	}	
}


