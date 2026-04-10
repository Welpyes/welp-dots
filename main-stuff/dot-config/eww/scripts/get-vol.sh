#!/bin/sh

get_volume() {
  pactl get-sink-volume OpenSL_ES_sink | awk '{print $5}' | head -n 1
}

get_volume

pactl subscribe | grep --line-buffered "sink" | while read -r _; do
  get_volume
done

