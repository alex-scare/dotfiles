#!/usr/bin/env bash

isMacOS() {
  [[ "$(uname -s)" == "Darwin" ]]
}

isArch() {
  [[ "$(uname -s)" == "Linux" ]] && command -v pacman >/dev/null 2>&1
}
