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
# xxx_yy_zz.json
# xxx se refiere al tipo de dato (trg,vel,acl,rgb) 
# yy es el identificador unico de configuracion (entero) y zz el indice en la secuencia
# /trg /pos /vel /acl /targets/posiciones/velocidades/aceleraciones de motores nparray de 5 x 20
# rgb imagen para leds nparray de 5 x 20 x 3

#ip list y puerto
iplist = ['192.168.0.11','192.168.0.12','192.168.0.13','192.168.0.14','192.168.0.15']
port = 8000
# dict osc commands
osc_tipo = {'pos':'/setPosition/', 'trg':'/setTarget/', 'vel':'/setVelocity/', 'acl':'/setAcceleration/', 'rgb':'/setColor/'}
file_tipo = {'pos':'trg', 'trg':'trg', 'vel':'vel', 'acl':'acl', 'rgb':'rgb'}
path = './data/' 

def byte_to_angle(value):
    return np.rint(90*(value-128)/86).astype(int)

def angle_to_byte(value):
    return np.clip(np.rint(86*value/90+128),1,255).astype(int)


def save_conf(npdata, nid, nseq=None, tipo='trg'):
    """guarda una configuracion 
    tipo 'trg' 'rgb' 'pos' 'vel' o 'acl'
    numero identificacion entero positivo nid
    si es una secuencia nseq indica el indice
    npdata array 2D o 3D (led)
    """
    print(npdata)
    if nseq:
        fname = path + file_tipo[tipo] + '_' + str(nid).zfill(2) + '_' + str(nseq).zfill(2) + '.json'
    else:
        fname = path + file_tipo[tipo] + '_' + str(nid).zfill(4) + '.json'
    with open(fname, 'w') as outfile:  
            json.dump(npdata, outfile, cls=NumpyEncoder)   

def load_conf(nid, nseq=None, tipo= 'trg'):
    """carga configuracion de archivo json 
    devuelve array numpy
    """
    if nseq:
        fname = path + file_tipo[tipo] + '_' + str(nid).zfill(2) + '_' + str(nseq).zfill(2) + '.json'
    else:
        fname = path + file_tipo[tipo] + '_' + str(nid).zfill(4) + '.json'
    with open(fname) as json_file:  
        npdata = json.load(json_file, object_hook=json_numpy_obj_hook)
        #perform someformat chequeo 
    return npdata

def print_conf(nid, nmod=0, nseq=None, tipo='trg'):
    npdata = load_conf(nid,nseq,tipo)
    if tipo == 'trg'or tipo == 'pos':
        npdata = byte_to_angle(npdata)
    data = np.reshape(npdata[nmod],(4,5))
    print(data)    


def send_config(config, nmod, tipo):
    """ envia una configuracion config a los modulos en la lista nmod
    si nmod es 0 lo envia a todos los modulos
    tipo es trg pos vel acl o rgb
    """
    if nmod:
        modlist = [iplist[n] for n in nmod]
    else:
        modlist = iplist
    if type(config) == np.ndarray:
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

def send_conf(nid, nseq=None, nmod = 0, tipo='trg'):
    """ envia la configuracion almacendad en archivo con numero num
    a los modulso en la lista nmod si nmod es 0 lo envia a todos
    tipo es trg pos vel acl o rgb
    """
    if tipo in osc_tipo.keys():
        config = load_conf(nid,nseq,tipo)
        send_config(config,nmod,tipo)    
    else:
        raise ValueError('formato o tipo invalido')

def send_conf_list(nums, mods, tipo = 'trg'):
    for n,num in enumerate(nums):
        send_conf(num, None, [mods[n]], tipo)

def send_conf_delay(nid, delays, nmod = 0, tipo = 'trg', loop =0):
    """ envia la secuencia de conifguracion que esta en conflist (numeros)
    en los intervalos dados por delays (valor fijo o lista)
    los otros parametros son los mismos que send_con
    si loop = 1 lo repite forever
    """
    for n,ndel in enumerate(delays):
        send_conf(nid, n+1, nmod, tipo)
        time.sleep(ndel)
    while(loop):
        for n,ndel in enumerate(delays):
            send_conf(nid, n+1, nmod, tipo)
            time.sleep(ndel)

def send_conf_random(nmod = 0, tipo = 'trg'):
    if tipo == 'rgb':
        config = np.random.randint(1, 255, size = (5,20,4))
    else:
        config = np.random.randint(1, 255, size = (5,20))
    send_config(config,nmod,tipo)

def send_rand_mask(nid,delay, nmask=0, nmod=0, tipo='trg'):
        """Envia la configuracion nid pero eligiendo columnas al azar para
        cada arduino en secuencia desde 1 hasta nmask con delay"""
        z = np.zeros((5,20),dtype=np.int32)
        for n in range(5):
            for m in range(4):
                z[n][m*5:(m+1)*5] = np.random.permutation(5)
        config = load_conf(nid,None,tipo)
        for n in nmask:
            config_p = config*(z==n)
            send_config(config_p, nmod, tipo)
            time.sleep(delay)

def make_conf_random(nid, tipo = 'trg'):
    """ arma una configuracion random y la almacena en nid
    """
    if tipo == 'rgb':
        npdata = np.random.randint(1,255,(5,20,4))
    else:
        npdata = np.random.randint(1,255,(5,20))
    save_conf(npdata,nid,None,tipo)

def make_conf(value, nid, nseq=None, clase='same', mod = 0, tipo='trg'):
    """arma una configuracion para uno o varios modulos 
    y la almacena en el archivo dado por num
    clase puede ser:
    same: todos las unidades con el mismo valor value
    col: lista de 4 valores por columnas
    row: lista de 5 valores por fila
    col12: lista de 8 valores por columnas pero para filas par/impar
    row12: lista de 10 valores por fila pero para columnas par/impar
    """
    if tipo == 'rgb':
        npdata = np.zeros((5,20,4), dtype = np.int32)
    else:
        npdata = np.zeros((5,20), dtype = np.int32)
    if mod == 0:
        modlist = range(5)
    for m in modlist:
        if clase == 'same':
            npdata[m] = value
        elif clase == 'col':
            for c in range(4):
                npdata[m][5*c:5*(c+1)] = value[c]
        elif clase == 'row':
            for r in range(5):
                npdata[m][r:20:5] = value[r]
        elif clase == 'col12':
            for c in range(4):
                npdata[m][5*c:5*(c+1)] = value[2*c]
                npdata[m][5*c+1:5*(c+1)] = value[2*c+1]     
        elif clase == 'row12':
            for r in range(5):
                npdata[m][r:20:10] = value[2*r]
                npdata[m][r+5:20:10] = value[2*r+1]
    print(npdata)            
    save_conf(npdata,nid,nseq,tipo)
