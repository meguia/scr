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

	void showModulo() {
	    for (int q = 0; q < 5; q++) {
		    OscMessage myMessage = new OscMessage("/setColor/0/elements/");
		    myMessage.add(0);
			for (int i = 0; i < 5; i++) {
				for (int j = 0; j < 4; j++) {
					float n = 0;
					if (modulo == q+1) n = 255;
		      		modulos[q][i*4+j].c = color(n,n,n);
		      		modulos[q][i*4+j].t = 0;
				}
			}
			//sendOSCMessage(myMessage, myRemoteLocation[q], true);
			sendMessage = true;
	    }			
	}

}


