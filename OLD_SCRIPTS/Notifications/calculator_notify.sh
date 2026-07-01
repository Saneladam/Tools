#!/bin/bash
notify-send -u low $(dmenu -c -p "calc" <&- | bc -l 2>/dev/null)
