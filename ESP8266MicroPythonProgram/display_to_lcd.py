"""Implements a HD44780 character LCD connected via PCF8574AT on I2C.
   This was tested with: ESP8266"""

from machine import I2C, Pin
from esp8266_i2c_lcd import I2cLcd
from micropython import const

# LCD display address is 0x3f
# The PCF8574AT address: 0x3F
DEFAULT_I2C_ADDR = 0x3F
print("Initializing LCD...")
i2c = I2C(-1, scl=Pin(5), sda=Pin(4), freq=400000)

_line_number = const(2)
_column_number = const(16)

lcd = I2cLcd(i2c, DEFAULT_I2C_ADDR, _line_number, _column_number)


# This function causes display flash. Use with caution.
# Prefer lcd_clear_one_line.
def lcd_clear():
    lcd.clear()  # Don't call clear often as it causes screen flash.


lcd_clear()
print("Initialized LCD.")


def _update_heartbeat_icon(char):
    lcd.move_to(_column_number - 1, 0)  # The right most column on the 1st row
    lcd.putchar(char)


# Erase whole screen.
# Don't call this function if text doesn't change; it will cause display flash.
def lcd_display(line1, line2=""):
    lcd_clear()
    lcd.move_to(0, 0)
    lcd.putstr(line1)
    # Don't use \n. It can force a line break, but causing wrong line position bug.
    # We know line index here and should use move_to.
    lcd.move_to(0, 1)
    lcd.putstr(line2)


# Erase one line content.
# y_index starts from 0, and max is _line_number - 1.
def lcd_clear_one_line(y_index):
    assert 0 <= y_index < _line_number
    lcd.move_to(0, y_index)
    # Erase one line by filling it with spaces
    # Reserve the last character for heart beat?
    lcd.putstr(' ' * _column_number)


# Update line1 and leave other lines intact
def lcd_display_line(line_index, line_content):
    lcd_clear_one_line(line_index)
    lcd.move_to(0, line_index)
    lcd.putstr(line_content)


heartbeat_count = 0


# Flip heartbeat icon each time this function is called, generating an animation
def update_lcd_heart_beat() -> None:
    global heartbeat_count
    heartbeat_count += 1
    if 0 != heartbeat_count % 2:
        _update_heartbeat_icon('*')
    else:
        _update_heartbeat_icon(' ')

# if __name__ == "__main__":
# lcd_display()
