"""Small example OSC client

This program sends 10 random values between 0.0 and 1.0 to the /filter address,
waiting for 1 seconds between each value.
"""
import argparse
import random
import time

from pythonosc import osc_message_builder
from pythonosc import udp_client


if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--ip", default="127.0.0.1",
      help="The ip of the OSC server")
  parser.add_argument("--port", type=int, default=8000,
      help="The port the OSC server is listening on")
  args = parser.parse_args()

  client1 = udp_client.SimpleUDPClient("192.168.0.11", 8000)
  client2 = udp_client.SimpleUDPClient("192.168.0.13", 8000)
  client3 = udp_client.SimpleUDPClient("192.168.0.14", 8000)
  client4 = udp_client.SimpleUDPClient("192.168.0.15", 8000)

    
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
    if cmd == 'a':
      client1.send_message("/setColor/0/all", [0,value_r,value_g,value_b,value_t])
      client2.send_message("/setColor/0/all", [0,value_r,value_g,value_b,value_t])
      client3.send_message("/setColor/0/all", [0,value_r,value_g,value_b,value_t])
      client4.send_message("/setColor/0/all", [0,value_r,value_g,value_b,value_t])
    
    else:
        client1.send_message("/setColor/0/element/"+str(nmot), [0,value_r,value_g,value_b,value_t])
        client2.send_message("/setColor/0/element/"+str(nmot), [0,value_r,value_g,value_b,value_t])
        client3.send_message("/setColor/0/element/"+str(nmot), [0,value_r,value_g,value_b,value_t])
        client4.send_message("/setColor/0/element/"+str(nmot), [0,value_r,value_g,value_b,value_t])
        print("/setColor/0/element/"+str(i))
