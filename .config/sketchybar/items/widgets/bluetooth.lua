local colors = require("colors")
local settings = require("settings")

-- Nerd Font (MDI) glyphs
local bt_icons = {
  Headphones = "󰋋",
  Headset = "󰋋",
  Mouse = "󰍽",
  Keyboard = "󰌌",
  other = "󰂱",
  on = "󰂯",
  off = "󰂲",
}

-- Prints "STATE|On" then "<minor type>|<name>|<battery>" per connected device
local bt_cmd = [[system_profiler SPBluetoothDataType 2>/dev/null | awk '
/^ *State:/ { print "STATE|" $2 }
/^ *Connected:$/ { c = 1; next }
/^ *Not Connected:$/ { if (n != "") print t "|" n "|" b; c = 0; n = "" }
c && /^          [^ ].*:$/ { if (n != "") print t "|" n "|" b; n = $0; sub(/^ +/, "", n); sub(/ *:$/, "", n); t = ""; b = "" }
c && /Minor Type:/ { t = $3 }
c && /^ *Battery Level:/ { b = $3 }
END { if (c && n != "") print t "|" n "|" b }']]

local popup_width = 250

local bluetooth = sbar.add("item", "widgets.bluetooth", {
  position = "right",
  update_freq = 15,
  icon = { drawing = false },
  label = {
    string = bt_icons.on,
    color = colors.grey,
    padding_left = 8,
    padding_right = 8,
    font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 16.0 },
  },
})

local bluetooth_bracket = sbar.add("bracket", "widgets.bluetooth.bracket", { bluetooth.name }, {
  background = { color = colors.bg1, corner_radius = 7, padding_left = 4, padding_right = 4 },
  popup = { align = "center" },
})

sbar.add("item", "widgets.bluetooth.padding", {
  position = "right",
  width = settings.group_paddings,
})

local devices = {}

local function icon_for(minor_type)
  return bt_icons[minor_type] or bt_icons.other
end

local function update()
  sbar.exec(bt_cmd, function(result)
    local state = "On"
    devices = {}
    for line in string.gmatch(result or "", "[^\n]+") do
      local a, b, c = line:match("^([^|]*)|([^|]*)|?([^|]*)$")
      if a == "STATE" then
        state = b
      elseif a then
        table.insert(devices, { type = a, name = b, battery = c })
      end
    end

    if state ~= "On" then
      bluetooth:set({ label = { string = bt_icons.off, color = colors.grey } })
    elseif #devices == 0 then
      bluetooth:set({ label = { string = bt_icons.on, color = colors.grey } })
    else
      local glyphs = {}
      for _, d in ipairs(devices) do table.insert(glyphs, icon_for(d.type)) end
      bluetooth:set({ label = { string = table.concat(glyphs, "  "), color = colors.white } })
    end
  end)
end

local popup_open = false

local function collapse_details()
  if not popup_open then return end
  popup_open = false
  bluetooth_bracket:set({ popup = { drawing = false } })
  sbar.remove("/widgets.bluetooth.device\\.*/")
end

local function toggle_details()
  if popup_open then
    collapse_details()
    return
  end
  sbar.remove("/widgets.bluetooth.device\\.*/")
  local rows = #devices > 0 and devices or { { type = "on", name = "No devices connected", battery = "" } }
  for i, d in ipairs(rows) do
    sbar.add("item", "widgets.bluetooth.device." .. i, {
      position = "popup." .. bluetooth_bracket.name,
      width = popup_width,
      icon = {
        string = icon_for(d.type),
        font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 16.0 },
      },
      label = { string = d.name .. (d.battery ~= "" and ("  " .. d.battery) or "") },
    })
  end
  popup_open = true
  bluetooth_bracket:set({ popup = { drawing = true } })
  update()
end

bluetooth:subscribe({ "routine", "forced", "system_woke" }, update)
bluetooth:subscribe("mouse.clicked", toggle_details)
bluetooth:subscribe("mouse.exited.global", collapse_details)
