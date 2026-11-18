local colors = require("colors")
local icons = require("icons")

local yabai = icons.yabai
-- Custom event fired by yabairc (window_focused signal), skhd and yabai/*.sh
sbar.add("event", "window_focus")

local yabai_item = sbar.add("item", "yabai", {
  position = "left",
  icon = {
    font = { size = 16.0 },
    string = yabai.grid,
    padding_left = 4,
    padding_right = 6,
    color = colors.white,
  },
  label = { drawing = false },
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1,
  },
  padding_left = 1,
  padding_right = 2,
})

-- One shell round-trip -> one `set`.  The previous version issued a *second*
-- nested sbar.exec for the stack branch while the other branches set the icon
-- immediately; window_focused, front_app_switched and space_change all fire on a
-- single Cmd-Tab, so callbacks interleaved and spliced two events' results
-- together (observed: grid icon carrying a "[2/2]" stack label).
--
-- Emits "layout|winstate|index|count":
--   layout   = the SPACE's layout (bsp|stack|float)   <- what ctrl+shift-{s,b,f} changes
--   winstate = the focused WINDOW's state             <- what alt-space / alt-f changes
-- These are two independent things; the old code only ever read the window, which
-- is why switching the space layout could not move the icon.
-- `count` counts only managed windows, and `index` falls back to 1: a lone managed
-- window in a stack space reports stack-index 0, which the old `> 0` test sent
-- down the else branch and rendered as "grid".
local STATE_QUERY = [==[
sp=$(yabai -m query --spaces --space 2>/dev/null)
ws=$(yabai -m query --windows --space 2>/dev/null)
[ -z "$sp" ] && exit 0
[ -z "$ws" ] && ws='[]'
jq -rn --argjson s "$sp" --argjson ws "$ws" '
  ($s.type) as $layout
  | ([$ws[] | select(.["is-floating"] == false)] | length) as $cnt
  | ([$ws[] | select(.["has-focus"] == true)] | first) as $w
  | (if $w == null then "none"
     elif ($w["has-fullscreen-zoom"] // false) then "fullscreen"
     elif ($w["has-parent-zoom"] // false) then "parent"
     elif ($w["is-floating"] // false) then "float"
     else "tiled" end) as $st
  | (if $w == null then 1
     elif (($w["stack-index"] // 0) > 0) then $w["stack-index"]
     else 1 end) as $idx
  | "\($layout)|\($st)|\($idx)|\($cnt)"'
]==]

-- Debounce: one Cmd-Tab fires window_focus + space_change/space_windows_change
-- back to back. Coalesce a burst into a single query and drop stale results.
local generation = 0

local function query_window_state(gen)
  sbar.exec(STATE_QUERY, function(result)
    if gen ~= generation then return end
    if not result then return end
    result = result:gsub("^%s*(.-)%s*$", "%1")
    if result == "" then return end

    local layout, state, idx, cnt = result:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
    if not layout or state == "none" then return end

    local icon, color, label

    if state == "fullscreen" then
      icon, color = yabai.fullscreen_zoom, colors.green
    elseif state == "parent" then
      icon, color = yabai.parent_zoom, colors.blue
    elseif layout == "float" then
      icon, color = yabai.float, colors.maroon
    elseif state == "float" then
      -- Space layout + a badge saying this particular window opted out of it.
      icon = (layout == "stack" and yabai.stack or yabai.grid) .. " " .. yabai.float
      color = colors.maroon
    elseif layout == "stack" then
      icon, color = yabai.stack, colors.red
      label = string.format("[%s/%s]", idx, cnt)
    else
      icon, color = yabai.grid, colors.orange
    end

    yabai_item:set({
      icon = { string = icon, color = color },
      label = label and { drawing = true, string = label } or { drawing = false },
    })
  end)
end

local function update_window_state()
  generation = generation + 1
  local gen = generation
  sbar.delay(0.05, function()
    if gen == generation then query_window_state(gen) end
  end)
end

yabai_item:subscribe("mouse.clicked", function()
  sbar.exec("yabai -m window --toggle float")
  sbar.delay(0.1, update_window_state)
end)

yabai_item:subscribe("window_focus", update_window_state)
yabai_item:subscribe("space_change", update_window_state)
yabai_item:subscribe("space_windows_change", update_window_state)

-- Initial state
sbar.delay(0.2, update_window_state)

return yabai_item
