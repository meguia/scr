""":
"""
# import argparse
import numpy as np
import json
import time
# from pythonosc import osc_message_builder
from pythonosc import udp_client
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import matplotlib.pyplot as plt
import matplotlib as mpl
from itertools import product

# Tipos de configuracionn
# xxx_yy_zz.json
# xxx se refiere al tipo de dato (trg,vel,acl,rgb)
# yy es el identificador unico de configuracion (entero) y zz el indice en la secuencia
# /trg /pos /vel /acl /targets/posiciones/velocidades/aceleraciones de motores nparray de 5 x 20
# rgb imagen para leds nparray de 5 x 20 x 3

# ip list y puerto
iplist = ['192.168.0.11', '192.168.0.12', '192.168.0.13', '192.168.0.14', '192.168.0.15']
port = 8000
# dict osc commands
osc_tipo = {'pos': '/setPosition/', 'trg': '/setTarget/', 'vel': '/setVelocity/', 'acl': '/setAcceleration/', 'rgb': '/setColor/'}
file_tipo = {'pos': 'trg', 'trg': 'trg', 'vel': 'vel', 'acl': 'acl', 'rgb': 'rgb'}

n_rows = 5
n_columns = 4

w = 0.25
d = 0.05
s = 1.2
#ucoord_base = [(-w - d, w + d), (-w - d, -w - d), (w + d, -w - d), (w + d, w + d),
#               (w - d, w + d), (w - d, -w + d), (-w + d, -w + d), (-w + d, w + d)]
ucoord_base = [(-w - d, -w - d), (w + d, -w - d), (w + d, w + d), (-w - d, w + d), 
               (-w - d, w - d), (w - d, w - d), (w - d, -w + d), (-w - d, -w + d)]

ij = list(product(range(n_columns), range(n_rows)))


def byte_to_angle(value):
    return np.rint(90 * (value - 128) / 86).astype(int)


def angle_to_byte(value):
    return np.clip(np.rint(86 * value / 90 + 128), 1, 255).astype(int)

def configname(nid, tipo='trg', path='configs/'):
    fname = path + tipo + '_' + str(nid).zfill(4) + '.json'	
    return fname

def save_config(values, filename, type_='trg', sequence=False):
    """guarda una configuracion
    tipo 'trg' 'rgb' 'pos' 'vel' o 'acl'
    """

    if sequence:
        data = []
        for v in values:
            if hasattr(v, 'tolist'):
                v = v.tolist()
            data.append({'type': type_, 'values': v})
    else:
        if hasattr(values, 'tolist'):
            values = values.tolist()
        data = {'type': type_, 'values': values}

    with open(filename, 'w') as outfile:
        json.dump(data, outfile)


def dump_json(data, filename):
    with open(filename, 'w') as outfile:
        json.dump(data, outfile)


def load_config(filename):
    """carga configuracion de archivo json
    devuelve array numpy
    """
    with open(filename) as json_file:
        data = json.load(json_file)
        if isinstance(data, list):
            for l in data:
                l['values'] = np.array(l['values'])
        else:
            data['values'] = np.array(data['values'])
        # perform someformat chequeo
    return data


def print_config(nid, nmod=0, nseq=None, type_='trg'):
    config = load_config(configname(nid, tipo=type_))
    if type(config) is dict:
        config = [config]
    for c in config:
        npdata = c['values']
        if type_ is 'trg'or tipo is 'pos':
            npdata = byte_to_angle(npdata)
        data = np.reshape(npdata[nmod], (4, 5))
        print(data)


def send_config(config, delay=None, plot=False, nmod=0):
    """ envia una configuracion config a los modulos en la lista nmod
    si nmod es 0 lo envia a todos los modulos
    tipo es trg pos vel acl o rgb
    """
    if nmod==0:
        nmod = list(range(5))
    modlist = [iplist[n] for n in nmod]
    if type(config) is dict:
        config = [config]
    for n,c in enumerate(config):
        if n:
            if delay is None:
                input()
            else:
                time.sleep(delay) 
        type_ = c.get('type', 'thr')
        if 'values' in c:
            values = c['values']
            if values.shape[:2] != (5, 20):
                raise ValueError('Configuracion no consistente con el formato')
            else:
                if plot:
                    nmodc = [x for x in range(5) if x not in nmod]
                    values[nmodc,:] = 0	
                    plot_scr(values.flatten())
                for n, ip in enumerate(modlist):
                    client = udp_client.SimpleUDPClient(ip, port)
                    osc_msg = osc_tipo[type_]
                    msg = [0]
                    for m, value in enumerate(values[nmod[n]]):
                        if np.isscalar(value):
                            msg.append(int(value))
                        else:
                            msg.extend(value.tolist())
                    print('Sending {} {}'.format(ip, str(msg)))
                    client.send_message(osc_msg, msg)
        else:
            raise ValueError('Missing values in config')

def load_send_config(filename, nmod=0):
    """ envia la configuracion almacendad en archivo con numero num
    a los modulso en la lista nmod si nmod es 0 lo envia a todos
    tipo es trg pos vel acl o rgb
    """
    config = load_config(filename)
    send_config(config, nmod=nmod)

def send_config_loop(config, delay, nloop=0, nmod=0):
    """ Envia la secuencia de configuracion de config en loop
    una cantidad de veces nloop con delay entre configuraciones delay
    """
    for n in range(nloop):
        try:
            send_config(config, delay=delay, plot=False, nmod=nmod)
            time.sleep(delay)
        except KeyboardInterrupt:
            break
        

def plot_scr(trg_values, n_modules=5):
    fig, ax = plt.subplots(figsize=(32, 8))
    u_idx = -1
    for k in range(n_modules):
        polygons = []
        for i, j in ij:
            u_idx += 1
            if trg_values[u_idx]:
                p = Polygon(ucoord_base, True)
                r = mpl.transforms.Affine2D().rotate(np.deg2rad(-byte_to_angle(trg_values[u_idx])))
                t = mpl.transforms.Affine2D().translate(j + k * (n_modules + 1), i)
                tra = r + t 
                p.set_transform(tra)
                polygons.append(p)
        patch = PatchCollection(polygons)
        patch.set_color([0, 0, 0])
        ax.add_collection(patch)
    plt.axis('off')
    plt.ylim(-1, n_columns)
    plt.xlim(-1, (n_rows + 1) * n_modules - 1)
    plt.gca().set_aspect('equal', 'box')


def send_rand_config(nmod=0, type_='trg', plot=False):
    if type_ is 'rgb':
        values = np.random.randint(1, 255, size=(5, 20, 4))
    else:
        values = np.random.randint(1, 255, size=(5, 20))
    send_config({'type': type_, 'values': values}, plot=plot, nmod=nmod)

def send_rand_mask(nid,delay, nmask=0, nmod=0, plot=False):
        """Envia la configuracion nid pero eligiendo columnas al azar para
        cada arduino en secuencia desde 1 hasta nmask con delay"""
        z = np.zeros((5,20),dtype=np.int32)
        for n in range(5):
            for m in range(4):
                z[n][m*5:(m+1)*5] = np.random.permutation(5)
        config = load_config(configname(nid))
        for n in nmask:
            config_p = config['values']*(z==n)
            send_config({'type': config['type'], 'values':config_p}, plot=plot, nmod=nmod)
            time.sleep(delay)

def make_config(value, clase='same', mod=0, tipo='trg'):
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
        npdata = np.zeros((5, 20, 4), dtype=np.int32)
    else:
        npdata = np.zeros((5, 20), dtype=np.int32)
    if mod == 0:
        mod = range(5)
    for m in mod:
        if clase is 'same':
            npdata[m] = value
        elif clase is 'col':
            for c in range(4):
                npdata[m][5 * c:5 * (c + 1)] = value[c]
        elif clase is 'row':
            for r in range(5):
                npdata[m][r:20:5] = value[r]
        elif clase is 'col12':
            for c in range(4):
                npdata[m][5 * c: 5 * (c + 1) : 2] = value[2 * c]
                npdata[m][5 * c + 1:5 * (c + 1) : 2] = value[2 * c + 1]
        elif clase is 'row12':
            for r in range(5):
                npdata[m][r:20:10] = value[2 * r]
                npdata[m][r + 5:20:10] = value[2 * r + 1] 		
    return npdata 
