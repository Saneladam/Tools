#!/usr/bin/env bash

headphones () {
  pacmd set-default-sink "alsa_output.pci-0000_00_1f.3.analog-stereo"
  move_streams
  notify-send "Audio switched to headphones!"
}

bluetooth () {
  pacmd set-default-sink "bluez_output.04_21_44_51_A3_32.1"
  move_streams
  notify-send "Audio switched to bluetooth!"
}

move_streams () {
  # Mueve todos los streams activos al nuevo sink por defecto
  for i in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$i" "$(pactl get-default-sink)"
  done
}

choosespeakers() {
  choice=$(printf "Headphones\nBluetooth" | dmenu -c -l 2 -i -p "Choose output: ")
  case "$choice" in
    Headphones) headphones;;
    Bluetooth) bluetooth;;
  esac
}

choosespeakers
