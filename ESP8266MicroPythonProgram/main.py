# Must plug in DC power to Lolin V3 board, to power its 3.3V and 5V rail to external devices like LCD/keypad.
import mpr121
from machine import Pin, I2C, PWM
import time

# i2c = I2C(3) # stm32
i2c = I2C(scl=Pin(5), sda=Pin(4))  # esp8266.
irq = Pin(0, Pin.IN, Pin.PULL_UP)
# i2c = I2C(scl=Pin(22), sda=Pin(21)) # esp32
# keypad address is 0x5A (match mpr121 library default)
mpr = mpr121.MPR121(i2c)

# LCD display address is 0x3f

# Buzzer at D5

# key is scan code
key_map = {1: 1, 2: 2, 4: 3, 8: 4, 16: 5, 32: 6, 64: 7, 128: 8, 256: 9, 512: 10, 1024: 11, 2048: 12}


def beep():
    beeper = PWM(Pin(14), freq=800, duty=512)
    time.sleep(0.1)
    beeper.deinit()


# check all keys
def check(_):
    touched_value = mpr.touched()
    if touched_value > 0:  # only interested in key down
        print("key pressed: {}".format(key_map[touched_value]))
        beep()


irq.irq(check, Pin.IRQ_FALLING)
