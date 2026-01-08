local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Active interface detection and dynamic event provider start
local active_if = "en0"
local provider_if = nil
local interface_type = "wifi" -- default to wifi

local function get_network_icons()
  return interface_type == "wifi" and icons.wifi or icons.ethernet
end

local function detect_interface_type(iface, callback)
  sbar.exec("networksetup -listallhardwareports | grep -A1 '" .. iface .. "' | grep 'Hardware Port:' | head -1", function(result)
    local port_info = string.gsub(result or "", "\n", "")
    local is_wifi = string.find(string.lower(port_info), "wi%-fi") ~= nil
    callback(is_wifi and "wifi" or "ethernet")
  end)
end

local function detect_active_interface(callback)
  sbar.exec("route -n get default | awk '/interface: /{print $2}'", function(result)
    local iface = string.gsub(result or "", "\n", "")
    if iface == nil or iface == "" then
      iface = active_if
    end
    detect_interface_type(iface, function(itype)
      interface_type = itype
      callback(iface)
    end)
  end)
end

local function start_network_provider(iface)
  if provider_if == iface then return end
  provider_if = iface
  sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load " .. iface .. " network_update 2.0")
end

-- Forward declaration - will be defined after widgets are created
local update_network_icons

-- Initialize provider for the current default route interface
detect_active_interface(function(iface)
  active_if = iface
  start_network_provider(active_if)
  if update_network_icons then update_network_icons() end -- Update icons after detecting interface type
end)

local popup_width = 250

local wifi_up = sbar.add("item", "widgets.wifi1", {
  position = "right",
  padding_left = -5,
  width = 0,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.wifi.upload, -- Will be updated later
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.red,
    string = "??? Bps",
  },
  y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
  position = "right",
  padding_left = -5,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.wifi.download, -- Will be updated later
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.blue,
    string = "??? Bps",
  },
  y_offset = -4,
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  label = { drawing = false },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name,
  wifi_up.name,
  wifi_down.name
}, {
  background = { color = colors.bg1 },
  popup = { align = "center", height = 30 }
})

local ssid = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    font = {
      style = settings.font.style_map["Bold"]
    },
    string = icons.wifi.router, -- Will be updated later
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"]
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15
  }
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  }
})

local ip = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local mask = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local router = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

wifi_up:subscribe("network_update", function(env)
  local up_color = (env.upload == "000 Bps") and colors.grey or colors.red
  local down_color = (env.download == "000 Bps") and colors.grey or colors.blue
  wifi_up:set({
    icon = { color = up_color },
    label = {
      string = env.upload,
      color = up_color
    }
  })
  wifi_down:set({
    icon = { color = down_color },
    label = {
      string = env.download,
      color = down_color
    }
  })
end)

update_network_icons = function()
  wifi_up:set({ icon = { string = get_network_icons().upload } })
  wifi_down:set({ icon = { string = get_network_icons().download } })
  ssid:set({ icon = { string = get_network_icons().router } })
end

wifi:subscribe({"wifi_change", "system_woke"}, function(env)
  detect_active_interface(function(iface)
    local previous_if = active_if
    active_if = iface
    if previous_if ~= active_if then
      start_network_provider(active_if)
      update_network_icons() -- Update icons when interface changes
    end
    sbar.exec("ipconfig getifaddr " .. active_if, function(ip)
      local connected = not (ip == "" or ip == nil)
      wifi:set({
        icon = {
          string = connected and get_network_icons().connected or get_network_icons().disconnected,
          color = connected and colors.white or colors.red,
        },
      })
    end)
  end)
end)

local function hide_details()
  wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set({ popup = { drawing = true }})
    sbar.exec("networksetup -getcomputername", function(result)
      hostname:set({ label = result })
    end)
    sbar.exec("ipconfig getifaddr " .. active_if, function(result)
      ip:set({ label = result })
    end)
    sbar.exec("ipconfig getsummary " .. active_if .. " | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      local label = string.gsub(result or "", "\n", "")
      if label == nil or label == "" then
        -- Fall back to interface type for non-Wi-Fi (e.g., Ethernet)
        sbar.exec("ipconfig getsummary " .. active_if .. " | awk -F 'InterfaceType : ' '/InterfaceType : / {print $2}'", function(t)
          local tlabel = string.gsub(t or "", "\n", "")
          if tlabel == nil or tlabel == "" then tlabel = "Network" end
          ssid:set({ label = tlabel })
        end)
      else
        ssid:set({ label = label })
      end
    end)
    sbar.exec("ipconfig getoption " .. active_if .. " subnet_mask", function(result)
      local label = string.gsub(result or "", "\n", "")
      mask:set({ label = label })
    end)
    sbar.exec("ipconfig getoption " .. active_if .. " router", function(result)
      local label = string.gsub(result or "", "\n", "")
      router:set({ label = label })
    end)
  else
    hide_details()
  end
end

wifi_up:subscribe("mouse.clicked", toggle_details)
wifi_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = icons.clipboard, align="center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
