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

local function update_window_state()
  sbar.exec("yabai -m query --windows --window 2>/dev/null | jq -r 'if . == null then \"none\" elif .[\"stack-index\"] > 0 then \"stack|\" + (.[\"stack-index\"] | tostring) elif .[\"is-floating\"] == true then \"float\" elif .[\"has-fullscreen-zoom\"] == true then \"fullscreen\" elif .[\"has-parent-zoom\"] == true then \"parent\" else \"grid\" end'", function(result)
    if not result or result == "" or result == "none" then return end
    result = result:gsub("^%s*(.-)%s*$", "%1")

    if result:match("^stack|") then
      local current = tonumber(result:match("^stack|(%d+)"))
      if current and current > 0 then
        sbar.exec("yabai -m query --windows --window stack.last 2>/dev/null | jq -r '.[\"stack-index\"]'", function(last_result)
          local last = tonumber(last_result) or current
          yabai_item:set({
            icon = { string = yabai.stack, color = colors.red },
            label = { drawing = true, string = string.format("[%d/%d]", current, last) },
          })
          set_border_color(colors.red)
        end)
      end
      return
    end

    if result == "float" then
      yabai_item:set({
        icon = { string = yabai.float, color = colors.maroon },
        label = { drawing = false },
      })
      set_border_color(colors.maroon)
    elseif result == "fullscreen" then
      yabai_item:set({
        icon = { string = yabai.fullscreen_zoom, color = colors.green },
        label = { drawing = false },
      })
      set_border_color(colors.green)
    elseif result == "parent" then
      yabai_item:set({
        icon = { string = yabai.parent_zoom, color = colors.blue },
        label = { drawing = false },
      })
      set_border_color(colors.blue)
    else
      yabai_item:set({
        icon = { string = yabai.grid, color = colors.orange },
        label = { drawing = false },
      })
      set_border_color(colors.white)
    end
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
yabai_item:subscribe("windows_on_spaces", update_windows_on_spaces)

-- Initial state
sbar.delay(0.2, update_window_state)

return yabai_item
