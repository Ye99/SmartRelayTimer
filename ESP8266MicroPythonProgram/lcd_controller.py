from display_to_lcd import lcd_display, update_lcd_heart_beat, lcd_display_line
from state import State


class LcdController:
    # LCD has states. There is only one LCD in this project and is shared.
    # Thus no need to create instance variable of LcdController
    last_state = State.INVALID

    def update_state_message(self, state):
        assert self.last_state != state

        if State.DISPLAYING_HISTORY_DATA == state:
            lcd_display_line(0, "5 mins 6/6 11:37")
        if State.INPUT_TIME == state:
            lcd_display_line(0, "S to Start")
        elif State.RUNNING == state:
            lcd_display_line(0, "Disinfecting...")
        elif State.PAUSED == state:
            lcd_display_line(0, "R to resume")

    def update_running_timer_message(self, timer):
        # assert State.RUNNING == self.last_state
        lcd_display_line(1, timer)