#!/bin/bash
echo "get /home/pi/I2C/cristal_osc_i2c_v_2_2.py" | sftp pi@192.168.0.11
ssh pi@192.168.0.11 -t /bin/ln -sf /home/pi/I2C/cristal_osc_i2c_v_2_2.py /home/pi/I2C/cristal_osc_i2c.py 
echo "put ./cristal_osc_i2c_v_2_2.py /home/pi/I2C/" | sftp pi@192.168.0.12
ssh pi@192.168.0.12 -t /bin/ln -sf /home/pi/I2C/cristal_osc_i2c_v_2_2.py /home/pi/I2C/cristal_osc_i2c.py 
echo "put ./cristal_osc_i2c_v_2_2.py /home/pi/I2C/" | sftp pi@192.168.0.13
ssh pi@192.168.0.13 -t /bin/ln -sf /home/pi/I2C/cristal_osc_i2c_v_2_2.py /home/pi/I2C/cristal_osc_i2c.py 
echo "put ./cristal_osc_i2c_v_2_2.py /home/pi/I2C/" | sftp pi@192.168.0.14
ssh pi@192.168.0.14 -t /bin/ln -sf /home/pi/I2C/cristal_osc_i2c_v_2_2.py /home/pi/I2C/cristal_osc_i2c.py 
echo "put ./cristal_osc_i2c_v_2_2.py /home/pi/I2C/" | sftp pi@192.168.0.15
ssh pi@192.168.0.15 -t /bin/ln -sf /home/pi/I2C/cristal_osc_i2c_v_2_2.py /home/pi/I2C/cristal_osc_i2c.py 
