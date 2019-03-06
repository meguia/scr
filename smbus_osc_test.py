import argparse

from pythonosc import dispatcher
from pythonosc import osc_server
from smbus2 import SMBusWrapper
from typing import List, Any


mega_addr = [0x04, 0x05, 0x06, 0x07]
nano_addr = [0x08, 0x09, 0x0a, 0x0b]

def msg_mega(cmd, nmot, value):
    msg = bytearray()
    msg.append(ord(cmd))
    msg.append(nmot)
    msg.extend(value.to_bytes(2, byteorder='big', signed = True))
    return msg

def default_handler(address: str, cmd, *values: List[Any]) -> None:
    nmot = address[-1]
    addr = mega_addr[2]
    data = msg_mega(cmd[0],int(nmot),int(values[0])) 
    print(data)
    try:
        with SMBusWrapper(1) as bus:
            bus.write_i2c_block_data(addr, 0, data)
    except IOError as err:
        print(err)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip",
                        default="127.0.0.1", help="The ip to listen on")
    parser.add_argument("--port",
                        type=int, default=8000, help="The port to listen on")
    args = parser.parse_args()

    dispatcher = dispatcher.Dispatcher()
    dispatcher.map("/vel*", default_handler, "v")
    dispatcher.map("/accel*", default_handler, "a")
    dispatcher.map("/step*", default_handler, "s")

    server = osc_server.ThreadingOSCUDPServer(
        (args.ip, args.port), dispatcher)
    print("Serving on {}".format(server.server_address))
    server.serve_forever()

