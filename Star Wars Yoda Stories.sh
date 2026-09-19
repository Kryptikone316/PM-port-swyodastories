#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
get_controls

GAMEDIR=/$directory/ports/swyodastories
BINARY=YodaStoriesNG.Engine

mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# ROCKNIX's own retrogame_joypad SDL mapping (guid
# 03009b4d4b4800000111000000010000) maps x/y by the label silkscreened on
# the pad (Nintendo layout: physical north is printed "X", physical west is
# printed "Y"), not by the physical position SDL's GameController API always
# requires (x=west, y=north, regardless of label). This game reads
# SDL_GameController buttons directly with no gptokeyb2 remap layer in
# between, so that swap made the physical north button fire this game's X
# binding (Travel/X-Wing - an unwanted zone change) instead of Y (Show
# Objective). Scoped fix: swap x/y back for just this one guid's entry.
export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG//x:b2,y:b3/x:b3,y:b2}"

export SDL_RENDER_DRIVER=opengles2

# This is a native SDL2 Wayland client running alongside EmulationStation
# under sway. Without the block below the game's window never gets focus
# or fullscreen - it launches as a small, unfocused surface behind ES. Same
# fix already proven on Vyruz/Flying Frogs/Anno 1602 AD: move ES to the
# scratchpad, focus+fullscreen our own window, restore ES on the way out
# via a trap so it fires on any exit path.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/0-runtime-dir}"
[ -z "$SWAYSOCK" ] && SWAYSOCK=$(ls "$XDG_RUNTIME_DIR"/sway-ipc.*.sock 2>/dev/null | head -1)
export SWAYSOCK
[ -z "$WAYLAND_DISPLAY" ] && WAYLAND_DISPLAY=$(basename "$(ls "$XDG_RUNTIME_DIR"/wayland-[0-9]* 2>/dev/null | head -1)")
export WAYLAND_DISPLAY

cleanup() {
  swaymsg '[app_id="emulationstation"] scratchpad show' >/dev/null 2>&1
  swaymsg '[app_id="emulationstation"] floating disable' >/dev/null 2>&1
  swaymsg '[app_id="emulationstation"] focus' >/dev/null 2>&1
}
trap cleanup EXIT INT TERM

swaymsg '[app_id="emulationstation"] move to scratchpad' >/dev/null 2>&1

# "YodaStoriesNG.Engine" is 20 chars, longer than the kernel's 15-char comm
# field - pkill would never match the full name, so pass a short prefix.
$GPTOKEYB2 "YodaStoriesNG" -c "$GAMEDIR/swyodastories.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

(
  sleep 1
  swaymsg '[app_id="YodaStoriesNG.Engine"] focus' >/dev/null 2>&1
  swaymsg '[app_id="YodaStoriesNG.Engine"] fullscreen enable' >/dev/null 2>&1
) &

./$BINARY

pm_finish
