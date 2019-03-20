# scr
Sonic Crystal Room

## Arquitectura
Hay 5 modulos de CS + Iris, cada uno con una raspi con IP fijo (mod1 .. mod5 iris los hostnames, y en el router SCR 192.168.0.11 - 16)
y una raspi master con IP fijo 192.168.0.10
La comunicacion entre el master y los modulos es mediante OSC. Cada modulo envia mensajes I2C a 4 arduino MEGA (motores) y 4 arduino NANO (luces) por cable de red

## Codigo

### cristal_osc_i2c
En cada uno de los modulos (y en Iris), corre cristal_osc_i2c como un servicio que basicamente traduce de OSC a I2C enviando mensajes a las arduino con la estructura comando + 20 valores. los 20 valores pueden ser 20 bytes (motores) u 80 bytes (LEDS), en este ultimo caso son siempre los valores de R G B y delay para el fader. En el caso de los motores depende del comando, por ejemplo 's' steps, el valor del 'angulo' de 1 (tope derecho) a 255 (tope izquierdo) siendo el medio 128. 

### control_readconfig 
se carga en el master y tiene varias funciones para armar, almacenar y enviar configuraciones por OSC
...

 
