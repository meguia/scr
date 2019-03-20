""":
"""
import argparse
import numpy as np
import json
import time
from npjson import *
from pythonosc import osc_message_builder
from pythonosc import udp_client

# Tipos de configuracionn
# xxx_zzzz.json
# xxx se refiere al tipo de dato (trg,vel,acl,rgb) 
# zzzz es el identificador unico de configuracion (entero)
# /trg /pos /vel /acl /targets/posiciones/velocidades/aceleraciones de motores nparray de 5 x 20
# rgb imagen para leds nparray de 5 x 20 x 3

#ip list y puerto
iplist = ['192.168.0.11','192.168.0.12','192.168.0.13','192.168.0.14','192.168.0.15']
port = 8000
# dict osc commands
osc_tipo = {'pos':'/setPosition/', 'trg':'/setTarget/', 'vel':'/setVelocity/', ' acl':'/setAcceleration/', 'rgb':'/setColor/'}
file_tipo = {'pos':'trg', 'trg':'trg', 'vel':'vel', 'acl':'acl', 'rgb':'rgb'}

def save_conf(npdata, num, tipo='pos'):
    """guarda una configuracion 
    tipo 'trg' 'rgb' 'pos' 'vel' o 'acl'
    numero identificacion entero positivo
    npdata array 2D o 3D (led)
    """
    print(npdata)
    fname = file_tipo[tipo] + '_' + str(num).zfill(4) + '.json'
    with open(fname, 'w') as outfile:  
            json.dump(npdata, outfile, cls=NumpyEncoder)   

def load_conf(num, tipo= 'trg'):
    """carga configuracion de archivo json 
    devuelve array numpy
    """
    fname = file_tipo[tipo] + '_' + str(num).zfill(4) + '.json'
    with open(fname) as json_file:  
        npdata = json.load(json_file, object_hook=json_numpy_obj_hook)
        #perform someformat chequeo 
    print(npdata)
    return npdata

def send_config(config, nmod, tipo):
    """ envia una configuracion config a los modulos en la lista nmod
    si nmod es 0 lo envia a todos los modulos
    tipo es trg pos vel acl o rgb
    """
    if nmod:
        modlist = [iplist[n] for n in nmod]
    else:
        modlist = iplist
    if type(config) is np.ndarray:
        if config.shape[:2] != (5, 20):
            raise ValueError('Configuracion no consistente con el formato')
        else:
            for n,ip in enumerate(modlist):
                client = udp_client.SimpleUDPClient(ip, port)
                osc_msg = osc_tipo[tipo]  
                msg = [0]
                for m,value in enumerate(config[n]):
                    if np.isscalar(value):
                        msg.append(int(value))
                    else:
                        msg.extend(value.tolist())
                print('Sending ' + ip + str(msg))
                client.send_message(osc_msg, msg) 
    else:
        raise ValueError('Configuracion con formato incorrecto')

def send_conf(num, nmod = 0, tipo='trg'):
    """ envia la configuracion almacendad en archivo con numero num
    a los modulso en la lista nmod si nmod es 0 lo envia a todos
    tipo es trg pos vel acl o rgb
    """
    if tipo in osc_tipo.keys():
        config = load_conf(num,tipo)
        send_config(config,nmod,tipo)    
    else:
        raise ValueError('formato o tipo invalido')

def send_conf_delay(conflist, delays, nmod = 0, tipo = 'trg', loop =0):
    """ envia la secuencia de conifguracion que esta en conflist (numeros)
    en los intervalos dados por delays (valor fijo o lista)
    los otros parametros son los mismos que send_con
    si loop = 1 lo repite forever
    """
    for n,num in enumerate(conflist):
        send_conf(num, nmod, tipo)
        time.sleep(delays[n])
    while(loop):
        for n,num in enumerate(conflist):
            send_conf(num, nmod, tipo)
            time.sleep(delays[n])


def make_conf(num, value, clase='same', mod = 0, tipo='trg'):
    """arma una configuracion para uno o varios modulos 
    y la almacena en el archivo dado por num
    clase puede ser:
    same: todos las unidades con el mismo valor value
    col: lista de 4 valores por columnas
    row: lista de 5 valores por fila
    col12: lista de 8 valores por columnas pero para filas par/impar
    row12: lista de 10 valores por fila pero para columnas par/impar
    """
    if tipo is 'rgb':
        npdata = np.zeros((5,20,4), dtype = np.int32)
    else:
        npdata = np.zeros((5,20), dtype = np.int32)
    if mod == 0:
        modlist = range(5)
    for m in modlist:
        if clase is 'same':
            npdata[m] = value
        elif clase is 'col':
            for c in range(4):
                npdata[m][5*c:5*(c+1)] = value[c]
        elif clase is 'row':
            for r in range(5):
                npdata[m][r:20:5] = value[r]
        elif clase is 'col12':
            for c in range(4):
                npdata[m][5*c:5*(c+1)] = value[2*c]
                npdata[m][5*c+1:5*(c+1)] = value[2*c+1]     
        elif clase is 'row12':
            for r in range(5):
                npdata[m][r:20:10] = value[2*r]
                npdata[m][r+5:20:10] = value[2*r+1]
    save_conf(npdata,num,tipo)
