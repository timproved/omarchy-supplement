#!/bin/bash

# Toggles the connected Bluetooth headset between hi-fi playback (A2DP, no mic)
# and headset mode (HFP, mic on). Auto-switching is disabled in
# 50-bluez-policy.conf so playback quality never drops unexpectedly.

set -euo pipefail

card=$(pactl list cards short | awk '$2 ~ /^bluez_card\./ { print $2; exit }')

if [[ -z $card ]]; then
  notify-send "Bluetooth audio" "No Bluetooth audio device connected"
  exit 0
fi

active=$(pactl list cards | awk -v card="$card" '
  $1 == "Name:" { in_card = ($2 == card) }
  in_card && /Active Profile:/ { print $3; exit }
')

if [[ $active == headset-head-unit ]]; then
  pactl set-card-profile "$card" a2dp-sink
  notify-send "Bluetooth audio" "Hi-fi (mic off)"
  exit 0
fi

pactl set-card-profile "$card" headset-head-unit

# The source node appears asynchronously after the profile switch.
address=${card#bluez_card.}
for _ in {1..20}; do
  source=$(pactl list sources short | awk -v a="$address" '$2 ~ "^bluez_input\\." a { print $2; exit }')
  [[ -n $source ]] && break
  sleep 0.1
done

if [[ -n ${source:-} ]]; then
  pactl set-default-source "$source"
fi

notify-send "Bluetooth audio" "Headset (mic on)"
