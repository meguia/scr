### esperar para trigerear
import numpy as np
import control_readconfig as ctrl

# MOV 1
#bajo la velocidad
ctrl.make_conf(1,255,tipo='vel')
ctrl.make_conf(1,255,tipo='acl')
ctrl.make_conf(2,50,tipo='vel')
ctrl.make_conf(2,50,tipo='acl')

crtl.send_conf(2,tipo='vel')
crtl.send_conf(2,tipo='acl')
#movimiento casi imperceptible
crtl.send_conf(2)
crtl.send_conf(1)

crtl.send_conf(1,tipo='vel')
crtl.send_conf(1,tipo='acl')
# MOV2
#escalonado

# MOV 3
# GLISSANDO

# MOV 4
############
# LABERINTO
# para atras todos
crtl.send_conf(2)

ctrl.make_conf_random(50)
ctrl.make_conf_random(51)
#posicion random de a pasos por columna elegida al azar
ctrl.send_conf_rand_mask(50,30,range(5))

# mueve de a 1 columna por fila al azar
ctrl.send_conf_rand_mask(51,0,nmask = 0)
ctrl.send_conf_rand_mask(1,0,nmask = 0, tipo='rgb')

ctrl.send_conf_rand_mask(51,0,nmask = 1)
ctrl.send_conf_rand_mask(1,0,nmask = 1, tipo='rgb')

ctrl.send_conf_rand_mask(51,0,nmask = 2)
ctrl.send_conf_rand_mask(1,0,nmask = 2, tipo='rgb')

ctrl.send_conf_rand_mask(51,0,nmask = 3)
ctrl.send_conf_rand_mask(1,0,nmask = 3, tipo='rgb')

ctrl.send_conf_rand_mask(51,0,nmask = 4)
ctrl.send_conf_rand_mask(1,0,nmask = 4, tipo='rgb')



# MOV 5
#######
# DUO DE SAXOS
ctrl.send_conf_list([5,6],[1,4])
ctrl.send_conf_list([6,5],[1,4])

# PARTE 2
ctrl.send_conf_list([7,8],[1,4])
ctrl.send_conf_list([7,7],[1,4])

# MOV 6
####
# Todos hacia el frente
ctrl.send_conf(1)

# PANOPTICO
#posiciones para izq y derecha de las columnas centrales, rapido luego abierndo simericas como camaras de seguridad
#configuraciones 12_01 12_02 13_01 13_02
ctrl.send_conf_delay(12,[2,2],loop=1)

ctrl.send_conf_delay(13,[2,2],loop=1)

ctrl.send_conf_delay(14,[2,2],loop=1)

# MOV 7
####
#CASA POLITICA
# Se apagan todos. Movimientos simetricos de los modulos 3 y 4 a 45
ctrl.send_conf_list([],nmod=[1,2],loop=1)

# MOV 8
####
# CASINO DE DIOS
# GIROS!


# MOV 9
####
# LA CATEDRAL

