from machine import Timer


class RelayController:
    def __init__(self, timer_initial_value_in_minutes):
        self.initial_timer_value_in_minutes = timer_initial_value_in_minutes
        self.remaining_timer_value_in_seconds = 0
        self.timer = Timer(-1)

    def start(self):
        self.remaining_timer_value_in_seconds = self.initial_timer_value_in_minutes * 60
        # self.timer.init(period=1000, mode=Timer.PERIODIC, callback=lambda t: self.timer_callback())
        pass

    def pause(self):
        pass

    def resume(self):
        pass

    def stop(self):
        pass

    def timer_callback(self):
        print("timer fired")
        self.remaining_timer_value_in_seconds -= self.remaining_timer_value_in_seconds
        pass
