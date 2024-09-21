class Strobo {
	int final_strobo;
	boolean inUse;
	int cristalIdx;

	Strobo(int idx) {
		cristalIdx = idx;
		inUse = false;
	}

	void strobo() {
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

	void draw() {
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