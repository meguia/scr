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

	void idle() {
		resetValues();
		pos++;
		if (pos > secuencia.length-1) pos = 0;
		valores[(int)secuencia[pos]/5][(int)secuencia[pos]%5] = 1;
	}

	void resetValues() {
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

	void idle() {
		if (secuencias.size() == 0) return;
		if (millis() > lastSequence + delayBetweenSequences) {
			pos++;
			if (pos > secuencias.size()-1) pos = 0;
			lastSequence = millis();
		}
	}


}