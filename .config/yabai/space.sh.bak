#!/usr/bin/env bash
# Focus (or send the focused window to) the Nth space of the display we are
# ACTUALLY on.  Usage: space.sh focus|move <n>
#
# Neither of the two obvious "which display am I on?" queries is trustworthy
# right after a keybind moves us to another display:
#
#   yabai -m query --displays --display        -> macOS' *active* display, which
#       yabai learns from NSWorkspaceActiveDisplayDidChangeNotification.  macOS
#       posts that only on a real mouse event or a space change on the other
#       screen; the cursor warp from mouse_follows_focus is not one, so this
#       keeps pointing at the display we came from.
#
#   yabai -m query --windows --window | .display  -> the focused window.  Right
#       when the target display's visible space has no focusable window,
#       `window --focus west` fails, `display --focus west` takes the
#       empty-display path, and focus never leaves the old display -- so this
#       answers confidently and wrongly.
#
# The cursor position is the one thing that is correct in both cases: yabai
# warps it on window focus AND on empty-display focus, and `--display mouse` is
# computed from the live cursor rect rather than from the stale notification.
set -u

action=${1:-focus}
n=${2:-1}

current_display() {
    local idx
    idx=$(yabai -m query --displays --display mouse 2>/dev/null | jq -r '.index // empty' 2>/dev/null)
    [ -n "$idx" ] && { echo "$idx"; return; }
    idx=$(yabai -m query --windows --window 2>/dev/null | jq -r '.display // empty' 2>/dev/null)
    [ -n "$idx" ] && { echo "$idx"; return; }
    yabai -m query --displays --display | jq -r '.index'
}

sid=$(yabai -m query --displays --display "$(current_display)" \
      | jq -r --argjson n "$n" '.spaces[$n - 1] // empty')
[ -n "$sid" ] || exit 0

case $action in
    focus) yabai -m space --focus "$sid" ;;
    move)  yabai -m window --space "$sid" ;;
esac
