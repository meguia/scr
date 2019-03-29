#!/bin/bash
ssh pi@192.168.0.11 -t /usr/sbin/i2cdetect -y 1 | head -2 | tail -1
ssh pi@192.168.0.12 -t /usr/sbin/i2cdetect -y 1 | head -2 | tail -1
ssh pi@192.168.0.13 -t /usr/sbin/i2cdetect -y 1 | head -2 | tail -1
ssh pi@192.168.0.14 -t /usr/sbin/i2cdetect -y 1 | head -2 | tail -1
ssh pi@192.168.0.15 -t /usr/sbin/i2cdetect -y 1 | head -2 | tail -1
ssh pi@192.168.0.12 -t /usr/sbin/i2cdetect -y 1 | head -2 | tail -1
