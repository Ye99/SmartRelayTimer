from convert_seconds_to_minutes_and_seconds import convert_seconds_to_minutes_and_seconds
from machine import Timer, Pin
from micropython import const

_one_second = const(1000)

# Relay at D6 (GPIO12).
# D6 is high at boot.
# Connect the relay to high trigger.
# Do not set relay to low trigger, because some ESP8266 high output isn't high enough to turn off the relay.
# Set relay to high trigger mode is more reliable.
relay = Pin(12, Pin.OUT)


class RelayController:
    def __init__(self, call_back_when_done, relay_high_trigger):
        self.initial_timer_value_in_minutes = 0
        self.remaining_timer_value_in_seconds = 0
        self.call_back_when_done = call_back_when_done
        self.relay_high_trigger = relay_high_trigger
        if self.relay_high_trigger:
            self._relay_on_value = const(1)
            self._relay_off_value = const(0)
        else:
            self._relay_on_value = const(0)
            self._relay_off_value = const(1)
        self.turn_off_relay()
        self.timer = Timer(-1)

    def turn_on_relay(self) -> None:
        relay.value(self._relay_on_value)

    def turn_off_relay(self) -> None:
        relay.value(self._relay_off_value)

    def reset(self):
        self.initial_timer_value_in_minutes = 0
        self.remaining_timer_value_in_seconds = 0

    def start(self, timer_initial_value_in_minutes):
        print("RelayController.start")
        self.initial_timer_value_in_minutes = timer_initial_value_in_minutes
        self.remaining_timer_value_in_seconds = self.initial_timer_value_in_minutes * 60
        self._schedule_timer()
        self.turn_on_relay()

    def pause(self):
        print("RelayController.pause")
        self.timer.deinit()
        self.turn_off_relay()

    def resume(self):
        print("RelayController.resume")
        self._schedule_timer()
        self.turn_on_relay()

    def cancel(self):
        # This can be called from timer callback. Don't use print.
        # print("RelayController.cancel")
        self.timer.deinit()
        self.turn_off_relay()
        completed_seconds = self.initial_timer_value_in_minutes * 60 - self.remaining_timer_value_in_seconds
        self.call_back_when_done(completed_seconds, self.initial_timer_value_in_minutes)
        # the callback needs this object state. Reset must be after the callback.
        self.reset()

    def _schedule_timer(self):
        self.timer.init(period=_one_second, mode=Timer.PERIODIC, callback=lambda t: self._timer_callback())

    def _timer_callback(self):
        if self.remaining_timer_value_in_seconds > 0:
            self.remaining_timer_value_in_seconds = self.remaining_timer_value_in_seconds - 1
        else:
            self.cancel()

    def get_remain_timer(self) -> str:
        return str(convert_seconds_to_minutes_and_seconds(self.remaining_timer_value_in_seconds))
