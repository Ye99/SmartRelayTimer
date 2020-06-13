# Must plug in DC power to Lolin V3 board, to power its 3.3V and 5V rail to external devices like LCD/keypad.
import mpr121
from machine import Pin, I2C, PWM
from time import sleep_ms, sleep
from display_to_lcd import lcd_display, update_lcd_heart_beat, lcd_display_line
from log import retrieve_metrics, save_metrics
from micropython import const

lcd_display("Booting...")

# i2c = I2C(3) # stm32
i2c = I2C(scl=Pin(5), sda=Pin(4))  # esp8266.
irq = Pin(0, Pin.IN, Pin.PULL_UP)
# i2c = I2C(scl=Pin(22), sda=Pin(21)) # esp32
# keypad address is 0x5A (match mpr121 library default)
mpr = mpr121.MPR121(i2c)

# Buzzer at D5

# key is scan code
key_map = {1: 1, 2: 2, 4: 3, 8: 4, 16: 5, 32: 6, 64: 7, 128: 8, 256: 9, 512: 10, 1024: 11, 2048: 12}


def beep():
    beeper = PWM(Pin(14), freq=800, duty=512)
    sleep(0.1)
    beeper.deinit()


key_value = 0

#is_key_value_changed=False
#def check_is_key_value_changed() -> bool:


# check all keys
def check(_):
    touched_value = mpr.touched()
    if touched_value > 0:  # only interested in key down
        global key_value
        key_value = key_map[touched_value]
        print("key pressed: {}".format(key_value))
        beep()


irq.irq(check, Pin.IRQ_FALLING)

lcd_display_line(0, "You pressed")

# This only impact LCD update time. Keybad is monitored by IRQ and should be realtime.
_loop_sleep_ms = const(50)

while True:
    try:

        lcd_display_line(1, str(key_value))
        sleep_ms(_loop_sleep_ms)
    except OSError as ex:
        error_message = 'ERROR: {}'.format(ex)
        # If function, invoked from here, raises exception, the loop can terminate.
        # publish_message(error_message)
        print(error_message)
