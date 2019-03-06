from smbus2 import SMBusWrapper
mega_addr = [0x04, 0x05, 0x06, 0x07]
nano_addr = [0x08, 0x09, 0x0a, 0x0b]
nbases = 5;

def msg_nano(cmd, nmot, value_r, value_g, value_b, value_t):
    msg = bytearray()
    msg.append(ord(cmd))
    msg.append(int(nmot%nbases))
    msg.append(value_b);
    msg.append(value_g);
    msg.append(value_r);
    msg.append(value_t);
    return msg

while True:
    cmd = input('Cmd:')
    nmot_input = input("LED 0-19:")
    nmot = int(nmot_input)
    value_input = input("Value red (0-255) :")
    value_r = int(value_input)
    value_input = input("Value green (0-255) :")
    value_g = int(value_input)
    value_input = input("Value blue (0-255) :")
    value_b = int(value_input)
    value_input = input("Duration (0-255) :")
    value_t = int(value_input)
    addr = nano_addr[nmot//nbases]
    data = msg_nano(cmd,nmot, value_r, value_g, value_b, value_t)
    if cmd == 'a':
        data = msg_nano('a',0,value_r, value_g, value_b, value_t)
        print(data)
        addr = 0x0
        try:
            with SMBusWrapper(1) as bus:
                bus.write_i2c_block_data(addr, 0, data)
        except IOError as err:
            print(err)        
        '''for i in [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]:
            data = msg_nano('m',i, value_r, value_g, value_b, value_t)
            print(data)
            addr = nano_addr[i//nbases]
            try:
                with SMBusWrapper(1) as bus:
                    bus.write_i2c_block_data(addr, 0, data)
            except IOError as err:
                print(err)'''
    else:
        print(data)
        try:
            with SMBusWrapper(1) as bus:
                bus.write_i2c_block_data(addr, 0, data)
        except IOError as err:
            print(err)
