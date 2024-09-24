JSONArray configuracion;
String[] filenames;

void loadDefaults() {
  try {
    configuracion = loadJSONArray("data/configuracion.json");
  } 
  catch (Exception e) {
    println("Error cargando los defaults: " + e.toString());
  }
}

JSONObject getConfiguracionEscena(int id) { // -1 para general, 0 en adelante para las escenas...
  loadDefaults();
  println("Cargando configuración para la escena " + id);
  
  for (int i = 0; i < configuracion.size(); i++) {
    JSONObject config = configuracion.getJSONObject(i); 
    if (config != null && config.getInt("id") == id) return configuracion.getJSONObject(i);
  }
  println("Atención! No se encontró la configuración de "+id);
  throw new java.lang.RuntimeException();
}

void setConfiguracionEscena(int id, JSONObject configuracion_particular) {
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

void resetEscenas() {
  for (int i = 0; i < escenas.size (); i++) escenas.get(i).setup();
}

AppBase getEscena(int nescena) {
  for (int i = 0; i < escenas.size (); i++) {
    if (escenas.get(i).id == nescena) {
      return escenas.get(i);
    }
  }
  return null;
}

// si está encendida la apagamos, si está apagada la encendemos
void switchEscena(int nescena) {
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

void setEscena(int nescena) {
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

void closeEscena(int nescena) {
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



void doSetEscena(int idescena) {
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
