#!/usr/bin/env bash
# Move the focused window one step in <dir>, across displays when needed.
# Usage: move.sh west|east|north|south
#
# Replaces the old inline chain, which had two defects:
#
#   yabai -m window --warp west || $(a && b && c) || yabai -m window --move rel:-10:0
#                                 ^^^^^^^^^^^^^^^
# 1. `$( )` is COMMAND SUBSTITUTION: it runs a/b/c and then executes their
#    stdout as a shell command.  Harmless only because yabai prints nothing on
#    success -- any future yabai build that writes to stdout would have its
#    output run as a command.  `{ ...; }` is what was meant.
# 2. `--warp last` fails with "cannot warp a window onto itself" when the target
#    display's space holds only this window.  That made the whole && chain
#    return non-zero, so the `|| --move rel:` fallback fired and printed
#    "cannot move a managed window" on every cross-display move.
#
# We also re-focus the window explicitly after the hop.  `display --focus` puts
# focus on whatever that display had focused before, and mouse_follows_focus
# then warps the cursor there instead of to the window you just moved -- which
# is what made the cursor look undecided between the two displays.
set -u

dir=${1:?usage: move.sh west|east|north|south}
case $dir in
    west)  rel="-10:0"; edge="last"  ;;
    east)  rel="10:0";  edge="first" ;;
    north) rel="0:-10"; edge=""      ;;
    south) rel="0:10";  edge=""      ;;
    *) echo "move.sh: bad direction '$dir'" >&2; exit 1 ;;
esac

# Remember the window before we move it; after `display --focus` the "focused
# window" is no longer ours.
wid=$(yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty')

# 1. Reorder within the current space.
if yabai -m window --warp "$dir" 2>/dev/null; then
    sketchybar --trigger window_focus
    exit 0
fi

# 2. Hand the window to the display in that direction and follow it there.
#    Strict directional: if no display lies that way, this fails and we fall
#    through -- `north`/`south` never reach a horizontally-arranged second
#    display, by design.
if yabai -m window --display "$dir" 2>/dev/null; then
    yabai -m display --focus "$dir" 2>/dev/null
    [ -n "$wid" ] && yabai -m window --focus "$wid" 2>/dev/null
    [ -n "$edge" ] && yabai -m window --warp "$edge" 2>/dev/null
    sketchybar --trigger window_focus
    exit 0
fi

# 3. Last resort: nudge a floating window. Managed windows legitimately refuse.
yabai -m window --move "rel:$rel" 2>/dev/null
sketchybar --trigger window_focus
exit 0
