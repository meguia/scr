#!/bin/bash
ssh pi@192.168.0.11 -t sudo sudo systemctl restart cristal.service 
ssh pi@192.168.0.12 -t sudo sudo systemctl restart cristal.service 
ssh pi@192.168.0.13 -t sudo sudo systemctl restart cristal.service 
ssh pi@192.168.0.14 -t sudo sudo systemctl restart cristal.service 
ssh pi@192.168.0.15 -t sudo sudo systemctl restart cristal.service 
