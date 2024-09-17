class Strobo {
	int final_strobo;
	boolean inUse, continousStrobe;
	int cristalIdx;

	Strobo(int idx) {
		cristalIdx = idx;
		inUse = false;
	}

	void strobo() {
		//if (cristalIdx < 1 || cristalIdx > 6) return;
		ColorWheel w = (ColorWheel)cp5.get("colorWheel");
	    for (int i = 0; i < 20; i++) {
	        modulos[cristalIdx][i].c = w.getRGB();
	    }
	    sendMessage = true;
	    inUse = true;
	    final_strobo = millis() + 20;
	}

	void draw() {
		if (continousStrobe && !inUse) strobo();
		if (inUse && millis() > final_strobo) {
		    for (int i = 0; i < 20; i++) {
		        modulos[cristalIdx][i].c = color(0);
		    }
		    sendMessage = true;
		    inUse = false;

		}
	}
}