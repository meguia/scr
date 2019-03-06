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

  #for x in range(100):
  while True:
    for i in range(1,20):
      r = int(random.random()*128)
      g = int(random.random()*128)
      b = int(random.random()*128)
      t = int(random.random()*100)
      client1.send_message("/setColor/0/all", [0,r,g,b,t])
      client2.send_message("/setColor/0/all", [0,r,g,b,t])
      client3.send_message("/setColor/0/all", [0,r,g,b,t])
      client4.send_message("/setColor/0/all", [0,r,g,b,t])
      print("/setColor/0/all")
      time.sleep(.05)
      client1.send_message("/setColor/0/all", [0,0,0,0,0])
      client2.send_message("/setColor/0/all", [0,0,0,0,0])
      client3.send_message("/setColor/0/all", [0,0,0,0,0])
      client4.send_message("/setColor/0/all", [0,0,0,0,0])
      time.sleep(.05)
    for i in range(0,4):
    #for i in range(0,1):
        client1.send_message("/setColor/0/all", [0,0,0,0,0])
        client2.send_message("/setColor/0/all", [0,0,0,0,0])
        client3.send_message("/setColor/0/all", [0,0,0,0,0])
        client4.send_message("/setColor/0/all", [0,0,0,0,0])
        time.sleep(.02)
        r = int(random.random()*64)
        g = int(random.random()*64)
        b = int(random.random()*64)
        t = 0 #int(random.random()*100)
        client1.send_message("/setColor/0/column/"+str(i), [0,r,g,b,t])
        client2.send_message("/setColor/0/column/"+str(i), [0,r,g,b,t])
        client3.send_message("/setColor/0/column/"+str(i), [0,r,g,b,t])
        client4.send_message("/setColor/0/column/"+str(i), [0,r,g,b,t])
        print("/setColor/0/column/"+str(i))
        time.sleep(1)

    for i in range(0,20):
        r = int(random.random()*24)
        g = int(random.random()*24)
        b = int(random.random()*24)
        t = int(random.random()*100)
        client1.send_message("/setColor/0/element/"+str(i), [0,r,g,b,t])
        client2.send_message("/setColor/0/element/"+str(i), [0,r,g,b,t])
        client3.send_message("/setColor/0/element/"+str(i), [0,r,g,b,t])
        client4.send_message("/setColor/0/element/"+str(i), [0,r,g,b,t])
        print("/setColor/0/element/"+str(i))
    time.sleep(2)

    for i in range(0,10):
        client1.send_message("/setColor/0/all", [0,0,0,0,0])
        client2.send_message("/setColor/0/all", [0,0,0,0,0])
        client3.send_message("/setColor/0/all", [0,0,0,0,0])
        client4.send_message("/setColor/0/all", [0,0,0,0,0])
        time.sleep(.02)
        c = int(random.random()*4)
        r = int(random.random()*64)
        g = int(random.random()*64)
        b = int(random.random()*64)
        t = 0 #int(random.random()*100)
        client1.send_message("/setColor/0/column/"+str(c), [0,r,g,b,t])
        client2.send_message("/setColor/0/column/"+str(c), [0,r,g,b,t])
        client3.send_message("/setColor/0/column/"+str(c), [0,r,g,b,t])
        client4.send_message("/setColor/0/column/"+str(c), [0,r,g,b,t])
        print("/setColor/0/column/"+str(i))
        time.sleep(.02)

