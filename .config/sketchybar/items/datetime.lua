local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Date item: shows "Mon, Mar 01"
local date = sbar.add("item", "date", {
  position = "right",
  icon = { drawing = false },
  label = {
    font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = 14 },
    padding_left = 4,
    padding_right = 4,
    color = colors.label_color,
  },
  update_freq = 60,
  click_script = "open -a Calendar.app",
})

-- Date popup details
sbar.add("item", "date.details", {
  position = "popup.date",
  icon = { drawing = false },
  label = { padding_left = settings.paddings, padding_right = settings.paddings },
})

-- Clock item: shows time with next event popup
local clock = sbar.add("item", "clock", {
  position = "right",
  icon = { drawing = false },
  label = {
    font = { family = settings.font.text, style = settings.font.style_map["Bold"], size = 14 },
    padding_left = 4,
    padding_right = 4,
    color = colors.label_color,
  },
  update_freq = 10,
  popup = { align = "right" },
  click_script = "sketchybar --set clock popup.drawing=toggle; open -a Calendar.app",
})

-- Next event popup (uses icalBuddy if available)
local clock_next = sbar.add("item", "clock.next_event", {
  position = "popup.clock",
  icon = { drawing = false },
  label = {
    padding_left = 0,
    max_chars = 32,
    scroll_duration = 100,
  },
})

local function update_date()
  date:set({ label = os.date("%a, %b %d") })
end

local function update_clock()
  clock:set({ label = os.date("%I:%M %p") })
end

local function update_next_event()
  sbar.exec("which icalBuddy 2>/dev/null", function(which_result)
    if which_result and which_result ~= "" then
      sbar.exec("/opt/homebrew/bin/icalBuddy -ec 'Found in Natural Language,CCSF' -npn -nc -iep 'datetime,title' -po 'datetime,title' -eed -ea -n -li 4 -ps '|: |' -b '' eventsToday 2>/dev/null | head -1", function(events)
        local text = (events and events ~= "") and events:gsub("\n", "") or "No events today"
        clock_next:set({ label = text })
      end)
    else
      clock_next:set({ label = "Install icalBuddy: brew install ical-buddy" })
    end
  end)
end

date:subscribe({ "routine", "system_woke" }, update_date)
clock:subscribe({ "routine", "forced", "system_woke" }, function()
  update_clock()
  update_next_event()
end)

clock:subscribe("mouse.entered", function()
  update_next_event()
  clock:set({ popup = { drawing = true } })
end)
clock:subscribe({ "mouse.exited", "mouse.exited.global" }, function()
  clock:set({ popup = { drawing = false } })
end)

-- Bracket around calendar to give it space and match other widgets
sbar.add("bracket", "calendar.bracket", { "date", "clock" }, {
  background = { color = colors.bg1, corner_radius = 7, padding_left = 4, padding_right = 10 },
})

sbar.add("item", "widgets.datetime.padding", {
  position = "right",
  width = settings.group_paddings
})

-- Initial update
sbar.delay(0.2, function()
  update_date()
  update_clock()
end)
