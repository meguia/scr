class Columna {
	int x, y, idx;
	color c;

	Columna() {

	}

	Columna(int _idx) {
		idx = _idx;
		x = idx / 5;
		y = idx % 5;
	}

	void draw(PGraphics pg) {
		pg.fill(c);
		if (brightness(c) < 220) pg.stroke(255);
		else pg.stroke(0);
		pg.rect(x*20,y*20,17,17);
	}
}