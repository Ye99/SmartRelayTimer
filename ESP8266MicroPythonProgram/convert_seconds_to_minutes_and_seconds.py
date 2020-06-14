# Not enough memory to load this 74K file:
# import datetime
# Use simple math to convert seconds to minutes.


def convert_seconds_to_minutes_and_seconds(seconds) -> str:
    minutes_value = int(seconds / 60)
    seconds_value = seconds % 60
    return "{minute}m {second}s ".format(minute=minutes_value, second=seconds_value)
