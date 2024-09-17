void initControladores() {

  cp5 = new ControlP5( this );
  cp5.addColorWheel("colorWheel" , width-250 , 10 , 200 ).setRGB(color(128,0,255));

  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 20; j++) {
      modulos[i][j] = new Columna(j);
    }
    cp5.addTextlabel("modulo " + (i+1))
                    .setText("modulo " + (i+1))
                    .setPosition(i*20*6+10,120)
                    .setColorValue(0xffffff00)
                    ;
    cp5.addButton("Girar-30-"+i)
     .setCaptionLabel("-30")
     .setPosition(i*20*6+20,140)
     .setSize(20,19)
     .setValue(0)
     .onRelease(new CallbackListener() { // add the Callback Listener to the button 
            public void controlEvent(CallbackEvent theEvent) {
              int modulo = int(theEvent.getController().getName().substring(theEvent.getController().getName().length()-1));
              println(theEvent.getController().getName() + ":"+modulo);
              rotarModulo(modulo, -PI/6);
            }
          }
      )
     ;    
    cp5.addButton("Girar+30-"+i)
     .setCaptionLabel("+30")
     .setPosition(i*20*6+45,140)
     .setSize(20,19)
     .setValue(0)
     .onRelease(new CallbackListener() { // add the Callback Listener to the button 
            public void controlEvent(CallbackEvent theEvent) {
              int modulo = int(theEvent.getController().getName().substring(theEvent.getController().getName().length()-1));
              rotarModulo(modulo,  PI/6);
            }
          }
      )
     ;    
    cp5.addButton("rellenar"+i)
     .setCaptionLabel("Rellenar módulo")
     .setPosition(i*20*6+10,170)
     .setSize(80,19)
     .setValue(0)
     .onRelease(new CallbackListener() { // add the Callback Listener to the button 
            public void controlEvent(CallbackEvent theEvent) {
              int modulo = int(theEvent.getController().getName().substring(theEvent.getController().getName().length()-1));
              rellenarModulo(modulo);
            }
          }
      )
     ;    
	cp5.addButton("estrobo-"+i)
     .setCaptionLabel("Estrobo")
     .setPosition(i*20*6+10,200)
     .setSize(80,19)
     .setValue(0)
	 .addCallback(new CallbackListener() {
		    public void controlEvent(CallbackEvent theEvent) {
	              int modulo = int(theEvent.getController().getName().substring(theEvent.getController().getName().length()-1));
		      switch(theEvent.getAction()) {
		        case(ControlP5.ACTION_PRESSED): strobos[modulo].continousStrobe = true; break;
		        case(ControlP5.ACTION_RELEASED): strobos[modulo].continousStrobe = false; break;
		      }
		    }
		  }
	  )
     ;  





  }	
	cp5.addButton("enviar_data")
	 .setCaptionLabel("Enviar colores")
	 .setPosition(10,270)
	 .setSize(100,19)
	 .setValue(0)
	 .onRelease(new CallbackListener() { // add the Callback Listener to the button 
	        public void controlEvent(CallbackEvent theEvent) {
	        	sendMessage = true;
	        }
	      }
	  )
	 ;    
	cp5.addTextfield("nombre_configuracion")
     .setPosition(10,370)
     .setSize(200,20)
     .setColor(color(255,255,255))
     .setVisible(true)
     ;	    
	cp5.addButton("guardar_configuracion")
	 .setCaptionLabel("Guardar")
	 .setPosition(220,370)
	 .setSize(100,19)
	 .setValue(0)
	 .onRelease(new CallbackListener() { // add the Callback Listener to the button 
	        public void controlEvent(CallbackEvent theEvent) {
	        	saveConfiguracion();
	        }
	      }
	  )
	 ; 

  getConfigurationList();
  cp5.addScrollableList("loadConfiguraciones")
     .setPosition(500, 300)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(filenames)
     .setLabel("Cargar configuracion")
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;
}

void loadConfiguracion() {
	/*String fn = cp5.get(ScrollableList.class, "configuraciones")
		.get
*/}


void loadConfiguraciones(int n) {
  /* request the selected item based on index n */
  String fn = "data/" + cp5.get(ScrollableList.class, "loadConfiguraciones").getItem(n).get("text");
  println("FN:::: " + fn);

  JSONArray valuesJSON = loadJSONArray(fn);
  int idx = 0;

  for (int q = 0; q < 6; q++) 
  	for (int i = 0; i < 20; i++) {
  		modulos[q][i].c = color(
  			Integer.parseInt(valuesJSON.getString(idx)),
  			Integer.parseInt(valuesJSON.getString(idx+1)),
  			Integer.parseInt(valuesJSON.getString(idx+2)));
  		idx += 3;
  	}
  
  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable 
   */
  
 
}

void saveConfiguracion() {
	String fn = cp5.get(Textfield.class, "nombre_configuracion")
		.getText();
	if (fn != "") {
		//int [] valores = new int[6*20*3];
		if (fn.length() < 5 || fn.substring(fn.length()-5) != "json") fn += ".json";
		fn = "data/"+fn;
		String valores = "[";
		for (int i = 0; i < 6; i++) 
			for (int j = 0; j < 20; j++) {
				/*valores[i*20*3+j*3+0] = (int)red(modulos[i][j].c);
				valores[i*20*3+j*3+1] = (int)green(modulos[i][j].c);
				valores[i*20*3+j*3+2] = (int)blue(modulos[i][j].c);*/
				valores += "\"" +(int)red(modulos[i][j].c) + "\",";
				valores += "\"" +(int)green(modulos[i][j].c) + "\",";
				valores += "\"" +(int)blue(modulos[i][j].c) + "\",";
			}
		valores += "\"\"]";

		JSONArray data = parseJSONArray(valores);
		saveJSONArray(data, fn);
	}
}


void rotarModulo(int modulo, float angulo) {
    rotaciones[modulo]-=angulo; 
}

void rellenarModulo(int modulo) {
    ColorWheel w = (ColorWheel)cp5.get("colorWheel");
    for (int i = 0; i < 20; i++)
    		modulos[modulo][i].c = w.getRGB();

}


void drawModulos() {

	performeDraw(columnasGraphics,false);
	performeDraw(columnasMouseChecker,true);
	image(columnasGraphics,0,0);
	//image(columnasMouseChecker,100,100);
}


void performeDraw(PGraphics pg, boolean setIndex) {
  pg.beginDraw();
  pg.background(0);
  pg.pushMatrix();
  pg.pushStyle();
  pg.translate(10,10);
  for (int i = 0; i < 6; i++) {
    pg.pushMatrix();
    pg.translate(40,50);
    pg.rotate(rotaciones[i]);
    pg.translate(-40,-50);
    for (int j = 0; j < 20; j++) {
    	if (setIndex) {
    		pg.fill(i*10,j*10,255);
    		pg.rect(modulos[i][j].x*20,modulos[i][j].y*20,17,17);
    	} else {
    		modulos[i][j].draw(pg);
    	}
    }
    pg.popMatrix();
    pg.translate(20*6,0);
  }
  pg.popStyle();
  pg.popMatrix();  
  pg.endDraw();
 }



void getConfigurationList() {
// Using just the path of this sketch to demonstrate,
  // but you can list any directory you like.
  String path = sketchPath();
  filenames = listFileNames(sketchPath()+"/data/");

}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

