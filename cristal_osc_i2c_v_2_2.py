# -*- coding: utf-8 -*-
'''
s: mover motores                                    OSC: /setTarget/
z: setea la posición (recibe la posición con valor) OSC: /setPosition/
p: parada de emergencia                             OSC: /stop/
v: velocidad                                        OSC: /setVelocity/
w: aceleración                                      OSC: /setAcceleration/
d: enable/disable 1/0                               OSC: /enable/ 
y: save to EEPROM (posición, velocidad, acel)       OSC: /save/

a: setea todos los leds a un solo color
m: 
'''

comandos = {
    'setTarget': 's',
    'setPosition': 'z',
    'stop': 'p',
    'setVelocity': 'v',
    'setAcceleration': 'w',
    'enable': 'd',
    'save': 'y',
    'setColor': 'M'
}

import argparse, json
import _thread
import time
import datetime
import syslog
import sys
from pythonosc import dispatcher
from pythonosc import osc_server
from smbus2 import SMBusWrapper
from typing import List, Any
#from npjson import *
#import json
#import numpy as np
import socket 
import random
#from scrconfig import *

bcID = 0
bcPOS = 1
bcTARGET = 2
bcVEL = 3
bcACCEL = 4
bcR = 5
bcG = 6
bcB = 7

def do_log(msg, level=syslog.LOG_INFO):
    print(str(datetime.datetime.now().timestamp()) + " " +msg)
    syslog.syslog(level, msg)


s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(('192.168.0.1', 0))
cristalip = (s.getsockname()[0])

do_log(("Cristal started with IP: " + str(cristalip)))


log_level = syslog.LOG_INFO #LOG_DEBUG

mega_addr = [0x04, 0x05, 0x06, 0x07]
nano_addr = [0x08, 0x09, 0x0a, 0x0b]
broadcast_addr = 0x00
nbases = 5;
# esto hay que hacerlo de alguna forma más automática, algo que dependa de la IP: 192.168.0.101 = 0, ... 
modulo = 0

message_queue = []
# la idea del flag request_status es avisarle a processsQueue() que necesitamos un update de cómo están los motores
# debería ser ejecutado cada tanto tiempo o a pedido de un cliente OSC y/o al iniciar el programa...
request_status = False 


def msg_nano_bus(cmd, values, idx):
    msg = bytearray()
    msg.append(ord(cmd))
    for i in range(0,20): # 5 leds x r,g,b,t = 20 valores
        msg.append(int(values[idx*20+i]))
    if len(values) == 81:
        msg.append(values[80])
    return msg

def msg_mega_bus(cmd, v0, v1, v2, v3, v4):
    msg = bytearray()
    msg.append(ord(cmd))
    msg.append(v0)
    msg.append(v1)
    msg.append(v2)
    msg.append(v3)
    msg.append(v4)
    return msg

def msg_motores_full(cmd, values):
    for i in range(0,4):
        send_message(mega_addr[i], msg_mega_bus(cmd, values[i*5+0], values[i*5+1], values[i*5+2], values[i*5+3], values[i*5+4]))
        #do_log(str(mega_addr[i]) + ": "+ str(msg_mega_bus(cmd, values[i*5+0], values[i*5+1], values[i*5+2], values[i*5+3], values[i*5+4])))


def msg_leds_full(values):
    for i in range(0,4):
        addr = nano_addr[i]
        data = msg_nano_bus('M', values, i)
        #do_log(str(data))
        send_message(addr, data)

        #do_log(str(addr) + ": "+ str(data))


def send_message(addr, data):
    global message_queue
    message_queue.append([data,addr])

def message_handler(address: str, cmd, *values: List[Any]) -> None:
    global comandos, message_queue
    do_log(address + " " + str(cmd) + " " + str(values))
    #if log_level == syslog.LOG_DEBUG:
    #    do_log(str(cmd))
    #    do_log(str(values))

    message_parsed = address.split("/")
    print(message_parsed[1])
    #print("Modificador"+ message_parsed[3]+message_parsed+" "+"R"+values[0]+"G"+values[1]+"B"+values[2]+"T"+values[3])

    # Primero verifico que sea para esta RPi:
    mensajes_motores = ['setPosition', 'setAcceleration', 'setTarget', 'enable', 'save', 'setVelocity']
    if message_parsed[1] == 'stopLeds': # Es un stop general de todo el módulo...
        do_log("Stop received!")
        #
        message_queue = []
        msg_leds_full([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
    elif message_parsed[1] == 'setColor':
        msg_leds_full(values)
    elif message_parsed[1] in mensajes_motores:
        msg_motores_full(comandos[message_parsed[1]],values)


def processQueue(arg1,arg2):
    global message_queue
    while True:
        if len(message_queue) > 0:
            print(len(message_queue))
            try:
                with SMBusWrapper(1) as bus:
                    arr = message_queue[0][0]
                    addr = message_queue[0][1] 
                    bus.write_i2c_block_data(addr, 0, arr)
                    del message_queue[0];
                    do_log(str(addr)+ ":" + str(arr))
                    #time.sleep(.001)
            except IOError as err:
                del message_queue[0];
                do_log(str(err), syslog.LOG_ERR)
            except Error as err:
                del message_queue[0];
                do_log(str(err), syslog.LOG_ERR)
            except Exception as e:
                del message_queue[0];
                do_log(str(e), syslog.LOG_ERR)
            except:
                del message_queue[0];
                do_log("Error en el processQueue", syslog.LOG_ERR)
        time.sleep(.02)
        '''
        comienzo_delay = time.time()
        while time.time() < comienzo_delay + 0.02:
            if len(message_queue) > 20: # es un valor arbitrario, pero para segurarnos de que no nos come el buffer...
                # recorremos la queue y dejamos solamente un único mensaje para cada Arduino
                do_log("Before cleaning up!"+str(len(message_queue)))
                listado = []
                i = len(message_queue) -1
                while i >= 0:
                    if message_queue[i][1] in listado:
                        message_queue.pop(i)
                    else:
                        listado.add(message_queue[i][1])
                    i = i-1
                do_log("After cleaning up!"+str(len(message_queue)))
        '''
        ###### read_i2c_block_data


try:
   _thread.start_new_thread( processQueue, ("ProcessQueue-1", 2, ) )
except Exception as e:
    do_log("Error: unable to start thread:"+str(e), syslog.LOG_ERR)


parser = argparse.ArgumentParser()
parser.add_argument("--ip",
                    default=cristalip, help="The ip to listen on")
parser.add_argument("--port",
                    type=int, default=8000, help="The port to listen on")
args = parser.parse_args()

dispatcher = dispatcher.Dispatcher()

dispatcher.map("*", message_handler)

server = osc_server.ThreadingOSCUDPServer(
    (args.ip, args.port), dispatcher)
do_log("Serving on {}".format(server.server_address))
server.serve_forever()
