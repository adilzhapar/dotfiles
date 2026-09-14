local colors = require("colors")
local icons = require("icons")
local app_icons = require("helpers.app_icons")

local yabai = icons.yabai
-- Create custom events for yabai triggers (from yabairc/skhd)
sbar.add("event", "window_focus")
sbar.add("event", "windows_on_spaces")

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

local function set_border_color(color_hex)
  local r = math.floor(color_hex / 65536) % 256
  local g = math.floor(color_hex / 256) % 256
  local b = color_hex % 256
  local hex = string.format("#%02x%02x%02x", r, g, b)
  sbar.exec("yabai -m config active_window_border_color " .. hex .. " 2>/dev/null &")
end

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

local function update_window_state()
  sbar.exec(STATE_QUERY, function(result)
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
    set_border_color(color == colors.orange and colors.white or color)
  end)
end

local function update_windows_on_spaces()
  sbar.exec("yabai -m query --displays 2>/dev/null | jq -r '.[].spaces | @sh'", function(display_spaces)
    if not display_spaces or display_spaces == "" then return end
    for line in display_spaces:gmatch("[^\r\n]+") do
      for space in line:gmatch("%S+") do
        sbar.exec("yabai -m query --windows --space " .. space .. " 2>/dev/null | jq -r '.[].app'", function(apps_result)
          local icon_strip = " "
          if apps_result and apps_result ~= "" then
            for app in apps_result:gmatch("[^\r\n]+") do
              app = app:gsub("^%s*(.-)%s*$", "%1")
              local icon = app_icons[app] or app_icons["Default"] or ":default:"
              icon_strip = icon_strip .. " " .. icon
            end
          end
          sbar.set("space." .. space, { label = { string = icon_strip, drawing = true } })
        end)
      end
    end
  end)
end

yabai_item:subscribe("mouse.clicked", function()
  sbar.exec("yabai -m window --toggle float")
  sbar.delay(0.1, update_window_state)
end)

yabai_item:subscribe("window_focus", update_window_state)
yabai_item:subscribe("front_app_switched", update_window_state)
yabai_item:subscribe("space_change", update_window_state)
yabai_item:subscribe("space_windows_change", update_window_state)
yabai_item:subscribe("windows_on_spaces", update_windows_on_spaces)

-- Initial state
sbar.delay(0.2, update_window_state)

return yabai_item
