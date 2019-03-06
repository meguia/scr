# -*- coding: utf-8 -*-
import argparse, json
import _thread
import time

from pythonosc import dispatcher
from pythonosc import osc_server
from smbus2 import SMBusWrapper
from typing import List, Any

# TODO:
# Hay que guardar el state y la configuración de cada LED
# Deberíamos probar enviara los arduinos el estado completo de una columna


mega_addr = [0x04, 0x05, 0x06, 0x07]
nano_addr = [0x08, 0x09, 0x0a, 0x0b]
nbases = 5;
# esto hay que hacerlo de alguna forma más automática, algo que dependa de la IP: 192.168.0.101 = 0, ... 
modulo = 0

message_queue = []



def msg_nano(cmd, nled, value_r, value_g, value_b, value_t):
    msg = bytearray()
    msg.append(ord(cmd))
    msg.append(int(nled%nbases))
    msg.append(int(value_r));
    msg.append(int(value_g));
    msg.append(int(value_b));
    msg.append(int(value_t));
    #msg.extend(value_t.to_bytes(2, byteorder='big', signed = False))
    return msg


def valid_values(values):
    return True

def send_message(data, addr):
    message_queue.append([data,addr])

def message_handler(address: str, cmd, *values: List[Any]) -> None:
    message_parsed = address.split("/")
    print("Modificador", message_parsed[3],message_parsed," ","R",values[0],"G",values[1],"B",values[2],"T",values[3])
    #print(cmd)
    #print(values)

    # Primero verifico que sea para esta RPi:
    if int(message_parsed[2]) == modulo:
        if message_parsed[1] == 'setColor':
            # print()
            # primero verifico y trimeo los valores
            r = max(0,min(255,values[0]))
            g = max(0,min(255,values[1]))
            b = max(0,min(255,values[2]))
            t = max(0,min(1023,values[3]))
            if not valid_values(values):
                print( "Error recibiendo los valores de RGB y Time" )
            else:
                # los modificadores posibles son: element, column, row, all, group (este no está aún definido)
                
                if message_parsed[3] == 'all':
                    for addidx in range(0,4):

                        data = msg_nano('a', 0, r, g, b, t)
                        #print(data)
                        addr = nano_addr[addidx]
                        send_message(data, addr)
                elif message_parsed[3] == 'column':
                    #for nled in range(0,5):
                    data = msg_nano('a', 0, r, g, b, t)
                    #print(data)
                    addr = nano_addr[int(message_parsed[4])]
                    send_message(data, addr)

                elif message_parsed[3] == 'element':
                    nled = int(message_parsed[4])
                    data = msg_nano('m', nled, r, g, b, t)
                    #print(data)
                    addr = nano_addr[nled//nbases]
                    send_message(data, addr)

def processQueue(arg1,arg2):
    while True:
        if len(message_queue) > 0:
            try:
                with SMBusWrapper(1) as bus:
                    arr = message_queue[0][0]
                    addr = message_queue[0][1] 
                    bus.write_i2c_block_data(addr, 0, arr)
                    del message_queue[0];
                    #time.sleep(.001)
            except IOError as err:
                print(err)
            except:
                print("Error en el processQueue")
        time.sleep(.025)


try:
   _thread.start_new_thread( processQueue, ("ProcessQueue-1", 2, ) )
except:
   print("Error: unable to start thread")


parser = argparse.ArgumentParser()
parser.add_argument("--ip",
                    default="127.0.0.1", help="The ip to listen on")
parser.add_argument("--port",
                    type=int, default=8000, help="The port to listen on")
args = parser.parse_args()

dispatcher = dispatcher.Dispatcher()

dispatcher.map("*", message_handler)

server = osc_server.ThreadingOSCUDPServer(
    (args.ip, args.port), dispatcher)
print("Serving on {}".format(server.server_address))
server.serve_forever()
