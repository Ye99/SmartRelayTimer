#!/bin/bash
curl -o .esp8266firmware.bin https://micropython.org/resources/firmware/esp8266-20200911-v1.13.bin
esptool.py --port /dev/ttyUSB0 erase_flash && esptool.py --port /dev/ttyUSB0 --baud 460800 write_flash --flash_size=detect 0 .esp8266firmware.bin && rshell -p /dev/ttyUSB0 --buffer-size=30