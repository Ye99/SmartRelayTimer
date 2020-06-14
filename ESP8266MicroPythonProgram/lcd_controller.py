from display_to_lcd import lcd_display, update_lcd_heart_beat, lcd_display_line
from state import State


class LcdController:
    # LCD has states. There is only one LCD in this project and is shared.
    # Thus no need to create instance variable of LcdController
    last_state = State.INVALID

    def update_state_message(self, state):
        assert self.last_state != state

        if State.DONE == state:
            lcd_display_line(0, "Done")
        if State.INPUT_TIME == state:
            lcd_display_line(0, "Press S to start")
        elif State.RUNNING == state:
            lcd_display_line(0, "Working...")
        elif State.PAUSED == state:
            lcd_display_line(0, "(R)esume(C)ancel")

    def update_message(self, message):
        lcd_display_line(1, message)
