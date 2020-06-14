# Must plug in DC power to Lolin V3 board, to power its 3.3V and 5V rail to external devices like LCD/keypad.
import mpr121
from machine import Pin, I2C, PWM
from time import sleep_ms, sleep
from log import retrieve_metrics, save_metrics
from micropython import const
from state import State
from relay_controller import RelayController
from lcd_controller import LcdController

# Keypad and LCD use D1, D2
i2c = I2C(scl=Pin(5), sda=Pin(4))  # esp8266.

# Keypad IRQ useds D3 (pin 0).
irq = Pin(0, Pin.IN, Pin.PULL_UP)

# Buzzer at D5 (GPIO14)
# Relay at D6 (GPIO12). See relay_controller.py for high/low trigger logic.

# keypad I2C address is 0x5A (match mpr121 library default)
mpr = mpr121.MPR121(i2c)

_start = "Start"
_pause = "Pause"
_resume = "Resume"
_cancel = "Cancel"

# key is scan code
key_map = {1: 1,
           2: 5,
           4: 10,
           8: 15,
           16: 20,
           32: 30,
           64: 45,
           128: 60,
           256: _start,
           512: _pause,
           1024: _resume,
           2048: _cancel}


def beep():
    beeper = PWM(Pin(14), freq=800, duty=512)
    sleep(0.1)
    beeper.deinit()


key_value = 0
last_key_value = key_value


def check_is_key_value_changed() -> bool:
    global last_key_value
    if key_value != last_key_value:
        last_key_value = key_value
        return True
    return False


# check all keys
def check(_):
    touched_value = mpr.touched()
    if touched_value > 0:  # only interested in key down
        global key_value
        key_value = key_map[touched_value]
        print("key pressed: {}".format(key_value))
        beep()


irq.irq(check, Pin.IRQ_FALLING)

# This only impact LCD update time. Keybad is monitored by IRQ and should be realtime.
_loop_sleep_ms = const(50)

_current_state = State.DONE

timer_initial_value_in_minutes = 0

lcd_controller = LcdController()
lcd_controller.update_state_message(State.DONE)

call_back_message = ""


def relay_time_done(message) -> None:
    global _current_state
    _current_state = State.DONE
    print("relay_time_done received: {}".format(message))
    global call_back_message
    call_back_message = message


relay_controller = RelayController(relay_time_done)

while True:
    try:
        if check_is_key_value_changed():
            if isinstance(key_value, int):
                if State.DONE == _current_state or State.INPUT_TIME == _current_state:
                    timer_initial_value_in_minutes = key_value
                    print("timer_initial_value_in_minutes set to {}".format(timer_initial_value_in_minutes))
                    _current_state = State.INPUT_TIME
            elif isinstance(key_value, str):
                if State.INPUT_TIME == _current_state and _start == key_value:
                    relay_controller.start(timer_initial_value_in_minutes)
                    _current_state = State.RUNNING
                elif State.RUNNING == _current_state:
                    if _pause == key_value:
                        relay_controller.pause()
                        _current_state = State.PAUSED
                    elif _cancel == key_value:
                        relay_controller.cancel()
                        _current_state = State.DONE
                elif State.PAUSED == _current_state:
                    if _resume == key_value:
                        relay_controller.resume()
                        _current_state = State.RUNNING
                    elif _cancel == key_value:
                        relay_controller.cancel()
                        _current_state = State.DONE

            lcd_controller.update_state_message(_current_state)

        if State.RUNNING == _current_state:
            remain_time = relay_controller.get_remain_timer()
            # print("lcd_controller.update_running_timer_message {}".format(remain_time))
            lcd_controller.update_message(remain_time)
        elif State.INPUT_TIME == _current_state:
            # print("Current input is {} minutes".format(timer_initial_value_in_minutes))
            lcd_controller.update_message("{} minutes".format(timer_initial_value_in_minutes))

        if len(call_back_message) > 0:
            lcd_controller.update_state_message(_current_state)
            lcd_controller.update_message(call_back_message)
            call_back_message = ""

        sleep_ms(_loop_sleep_ms)
    except OSError as ex:
        error_message = 'ERROR: {}'.format(ex)
        # If function, invoked from here, raises exception, the loop can terminate.
        # publish_message(error_message)
        print(error_message)

relay_controller.cancel()
