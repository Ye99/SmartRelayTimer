from machine import Timer, Pin
from micropython import const


# Not enough memory to load this 74K file:
# import datetime
# Use simple math to convert seconds to minutes.
def convert_seconds_to_minutes_seconds(seconds) -> str:
    minutes_value = int(seconds / 60)
    seconds_value = seconds % 60
    return "{minute}m {second}s ".format(minute=minutes_value, second=seconds_value)


_one_second = const(1000)

# Relay at D6 (GPIO12).
# D6 is high at boot.
# Connect the relay to low trigger.
relay = Pin(12, Pin.OUT)


def turn_on_relay() -> None:
    relay.value(0)


def turn_off_relay() -> None:
    relay.value(1)


turn_off_relay()


class RelayController:
    def __init__(self, call_back_when_done):
        self.initial_timer_value_in_minutes = 0
        self.remaining_timer_value_in_seconds = 0
        self.call_back_when_done = call_back_when_done
        self.timer = Timer(-1)

    def start(self, timer_initial_value_in_minutes):
        print("RelayController.start")
        self.initial_timer_value_in_minutes = timer_initial_value_in_minutes
        self.remaining_timer_value_in_seconds = self.initial_timer_value_in_minutes * 60
        self._schedule_timer()
        turn_on_relay()

    def pause(self):
        print("RelayController.pause")
        self.timer.deinit()
        turn_off_relay()

    def resume(self):
        print("RelayController.resume")
        self._schedule_timer()
        turn_on_relay()

    def cancel(self):
        print("RelayController.cancel")
        self.timer.deinit()
        turn_off_relay()
        done_in_seconds = self.initial_timer_value_in_minutes * 60 - self.remaining_timer_value_in_seconds
        message = "Finished {}".format(str(convert_seconds_to_minutes_seconds(done_in_seconds)))
        self.call_back_when_done(message)

    def _schedule_timer(self):
        self.timer.init(period=_one_second, mode=Timer.PERIODIC, callback=lambda t: self._timer_callback())

    def _timer_callback(self):
        # print("timer fired")
        if self.remaining_timer_value_in_seconds > 0:
            self.remaining_timer_value_in_seconds = self.remaining_timer_value_in_seconds - 1
        else:
            self.cancel()


    def get_remain_timer(self) -> str:
        return str(convert_seconds_to_minutes_seconds(self.remaining_timer_value_in_seconds))
