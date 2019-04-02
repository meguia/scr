import time
import serial

ser=serial.Serial(port='/dev/ttyUSB0',baudrate=9600,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS,timeout=1)
while True:
	cmd = input('Comando:')
	ser.write(counter)
Ser.close
