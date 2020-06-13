"""
Side effect: turns off AP
#Connect to the ssid and pwd
"""

STAT_GOT_IP = 5

import time
import ubinascii

wait_connection_milliseconds = 30000  # Do not wait too long, other WDT will reset MCU.


def do_connect(ssid, pwd) -> bool:
    import network

    print('Turn off AP for security.')
    sta_ap = network.WLAN(network.AP_IF)
    sta_ap.active(False)

    sta_if = network.WLAN(network.STA_IF)

    sta_if.active(False)
    while sta_if.active():
        pass

    sta_if.active(True)
    while not sta_if.active():
        pass

    print('Connecting to network', ssid, "...")

    start = time.ticks_ms()
    sta_if.connect(ssid, pwd)
    while not sta_if.isconnected():
        if time.ticks_diff(time.ticks_ms(), start) > wait_connection_milliseconds:
            return False

    while sta_if.status() != STAT_GOT_IP:
        pass

    print('Connected to network ', ssid, '. ifconfig is ', sta_if.ifconfig())

    mac = ubinascii.hexlify(network.WLAN().config('mac'), ':').decode()
    print("mac address is {}".format(mac))

    return True
