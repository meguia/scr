from smbus2 import SMBusWrapper
mega_addr = [0x04, 0x05, 0x06, 0x07]
broadcast_addr = 0x00
#nano_addr = [0x08, 0x09, 0x0a, 0x0b]
nbases = 5
cmdlist = []
comandos_permitidos = 'svazSVAZpqrPQR'

def msg_mega(cmd, nmot, value):
    msg = bytearray()
    msg.append(ord(cmd))
    msg.append(nmot%nbases)
    msg.extend(value.to_bytes(2, byteorder='big', signed = True))
    return msg

def check_input(c):
    if (len(c) != 3):
        return False
    if len(cmdlist[0]) > 1:
        if cmdlist[0][0] == 'b':
            print('broadcast')
            cmdlist[0] = cmdlist[0][1]
            cmdlist.append('b') 
        else:
            return False
    if cmdlist[0] not in comandos_permitidos:
        print('comamndos : ' + comandos_permitidos)
        return False
    try: 
        nmotor = int(cmdlist[1])
        if (nmotor > 19):
            print('Motor debe ser menor a 20')
            return False
    except ValueError:
        print('segundo argumento debe ser el num de motor')
        return False
    try:
        value = int(cmdlist[2])
        if ( abs(value) > 2 ** 15):
            print('valor demasiado alto')
            return False
    except ValueError:
        print('tercer argumento debe ser un entero') 
        return False
    return True

while True:
    while not check_input(cmdlist):
        cmd = input('Comando,nummotor,value:')
        cmdlist = cmd.split(',')
    if (cmdlist[0] == 'r'):
        addr = mega_addr[int(cmdlist[1])]
        cmdlist = []
        #try:
        #    with SMBusWrapper(1) as bus:
        #        bloque = bus.read_i2c_block_data(addr,0,20);
        #    print(bloque)    
        #except IOError as err:
        #    print(err)
    else :
        nmotor = int(cmdlist[1])
        value = int(cmdlist[2])
        if (len(cmdlist) == 3):
            addr = mega_addr[nmotor//nbases]
            cmd = cmdlist
        else:
            addr = broadcast_addr
        data = msg_mega(cmdlist[0],nmotor,value)
        print(data)
        cmdlist = []
        try:
            with SMBusWrapper(1) as bus:
                bus.write_i2c_block_data(addr, 0, data)
        except IOError as err:
            print(err)
