#!/usr/bin/env bash
set -euo pipefail

choose_rofi() {
  rofi -dmenu -i -p "$1"
}

bt_show() {
  local out ctrl

  out="$(bluetoothctl show 2>/dev/null || true)"
  if [[ -n "$out" && "$out" != *"No default controller available"* ]]; then
    printf '%s\n' "$out"
    return 0
  fi

  ctrl="$(bluetoothctl list 2>/dev/null | sed -n 's/^Controller[[:space:]]\+\([^[:space:]]\+\).*/\1/p' | head -n1)"
  if [[ -n "$ctrl" ]]; then
    bluetoothctl show "$ctrl" 2>/dev/null || true
  fi
}

bt_field() {
  local key="$1"
  bt_show | sed -n "s/^[[:space:]]*${key}:[[:space:]]*//p" | head -n1 | tr '[:upper:]' '[:lower:]'
}

rfkill_power_state() {
  local out
  out="$(rfkill list bluetooth 2>/dev/null || true)"
  [[ -z "$out" ]] && return 1

  if printf '%s\n' "$out" | grep -q "Hard blocked: yes"; then
    printf '%s\n' "no"
    return 0
  fi

  if printf '%s\n' "$out" | grep -q "Soft blocked: no"; then
    printf '%s\n' "yes"
    return 0
  fi

  if printf '%s\n' "$out" | grep -q "Soft blocked: yes"; then
    printf '%s\n' "no"
    return 0
  fi

  return 1
}

power_state() {
  local p
  p="$(rfkill_power_state || true)"
  if [[ "$p" == "yes" || "$p" == "no" ]]; then
    printf '%s\n' "$p"
    return 0
  fi

  p="$(bt_field Powered)"
  if [[ "$p" == "yes" || "$p" == "no" ]]; then
    printf '%s\n' "$p"
    return 0
  fi

  printf '%s\n' "unknown"
}

is_powered() {
  [[ "$(power_state)" == "yes" ]]
}

connected_devices() {
  local mac name
  bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
    [[ -z "${mac:-}" ]] && continue
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
      printf '%s %s\n' "$mac" "${name:-}"
    fi
  done
}

known_devices() {
  bluetoothctl devices 2>/dev/null | sed -n 's/^Device //p' | awk 'NF && !seen[$0]++'
}

scan_devices() {
  local scanned
  scanned="$(
    bluetoothctl --timeout 6 scan on 2>/dev/null \
      | sed -n 's/^.*Device \([0-9A-F:]\{17\}\)[[:space:]]\+\(.*\)$/\1 \2/p' \
      | awk 'NF && !seen[$0]++'
  )"

  {
    [[ -n "$scanned" ]] && printf '%s\n' "$scanned"
    known_devices
  } | awk 'NF && !seen[$0]++'
}

connect_menu() {
  local pick mac
  pick="$(known_devices | choose_rofi "Connect")"
  [[ -z "$pick" ]] && exit 0
  mac="${pick%% *}"
  bluetoothctl connect "$mac" >/dev/null
}

disconnect_menu() {
  local pick mac
  pick="$(connected_devices | choose_rofi "Disconnect")"
  [[ -z "$pick" ]] && exit 0
  mac="${pick%% *}"
  bluetoothctl disconnect "$mac" >/dev/null
}

search_menu() {
  local devices pick mac

  if ! is_powered; then
    bluetoothctl power on >/dev/null 2>&1 || rfkill unblock bluetooth >/dev/null 2>&1 || true
    sleep 0.3
  fi

  while true; do
    devices="$(scan_devices)"
    pick="$(
      {
        printf '%s\n' "󰚰 Scan Again (4s)"
        if [[ -n "$devices" ]]; then
          printf '%s\n' "$devices"
        else
          printf '%s\n' "No devices found"
        fi
      } | choose_rofi "Search + Connect"
    )"

    [[ -z "$pick" ]] && return 0

    case "$pick" in
      "󰚰 Scan Again (4s)"|"No devices found")
        continue
        ;;
      *)
        mac="${pick%% *}"
        bluetoothctl connect "$mac" >/dev/null 2>&1 || true
        return 0
        ;;
    esac
  done
}

main_menu() {
  local pick powered discovering pairable power_action status_line
  powered="$(power_state)"
  discovering="$(bt_field Discovering)"
  pairable="$(bt_field Pairable)"

  [[ -z "$powered" ]] && powered="unknown"
  [[ -z "$discovering" ]] && discovering="unknown"
  [[ -z "$pairable" ]] && pairable="unknown"

  status_line="Status: Powered=${powered}"
  if [[ "$discovering" != "unknown" ]]; then
    status_line="${status_line} Discovering=${discovering}"
  fi
  if [[ "$pairable" != "unknown" ]]; then
    status_line="${status_line} Pairable=${pairable}"
  fi

  if [[ "$powered" == "yes" ]]; then
    power_action="Power Off"
  else
    power_action="Power On"
  fi

  pick="$(
    printf '%s\n' \
      "$status_line" \
      "$power_action" \
      "Connect" \
      "Disconnect" \
      "Search + Connect" | choose_rofi "Bluetooth"
  )"

  case "$pick" in
    "Status: "*)
      return 0
      ;;
    "Power On")
      bluetoothctl power on >/dev/null 2>&1 || rfkill unblock bluetooth >/dev/null 2>&1 || true
      ;;
    "Power Off")
      if is_powered; then
        bluetoothctl power off >/dev/null 2>&1 || rfkill block bluetooth >/dev/null 2>&1 || true
      fi
      ;;
    "Connect") connect_menu ;;
    "Disconnect") disconnect_menu ;;
    "Search + Connect") search_menu ;;
  esac
}

if [[ "${1:-}" == "--menu" ]]; then
  main_menu
  exit 0
fi

if [[ "${1:-}" == "--search" ]]; then
  search_menu
  exit 0
fi

if ! is_powered; then
  echo "󰂲"
  exit 0
fi

conn="$(connected_devices)"
if [[ -n "$conn" ]]; then
  # Show first connected device only to keep module compact.
  echo "󰂱 ${conn#* }"
else
  echo "󰂯"
fi
