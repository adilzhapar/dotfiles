#!/usr/bin/env bash
# Switch the focused space's layout.  Usage: layout.sh bsp|stack|float
#
# A floating window is OUTSIDE yabai's window tree: `space --layout` reshuffles
# the tree, so a space whose windows are all floating looks completely inert when
# you switch layouts.  That is why ctrl+shift-{s,b} appeared to do nothing.
# Before switching to a managed layout we therefore drop every floating window on
# the space back under management.  `--float off` does not exist; `--toggle float`
# is safe here because we only ever select windows that are already floating.
set -u

mode=${1:-bsp}

if [ "$mode" != "float" ]; then
    for wid in $(yabai -m query --windows --space \
                 | jq -r '.[] | select(.["is-floating"] == true) | .id'); do
        yabai -m window "$wid" --toggle float 2>/dev/null
    done
fi

yabai -m space --layout "$mode"
[ "$mode" = "bsp" ] && yabai -m space --balance 2>/dev/null

sketchybar --trigger window_focus
