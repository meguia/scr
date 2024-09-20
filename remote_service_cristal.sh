#!/bin/bash
ssh pi@192.168.0.11 -t sudo systemctl status cristal.service | head -1
ssh pi@192.168.0.12 -t sudo systemctl status cristal.service | head -1
ssh pi@192.168.0.13 -t sudo systemctl status cristal.service | head -1
ssh pi@192.168.0.14 -t sudo systemctl status cristal.service | head -1
ssh pi@192.168.0.15 -t sudo systemctl status cristal.service | head -1
