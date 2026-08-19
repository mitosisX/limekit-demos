-- Dates, times and timers.
--
-- Two 1.x methods here could not have worked and were replaced rather than
-- reproduced: TimePicker:setDate(y, m, d) fed a date into a time widget, and
-- DatePicker:setDate took hour and minute arguments that were never shown.

local ui = require("limekit.ui")
local sys = require("limekit.sys")

local window = ui.Window { title = "Date & Time - Limekit 2.0", size = { 620, 520 } }

local report = ui.TextField()
report:setReadOnly(true)

local function say(message)
    report:appendText(message)
end

-- A full month view.
local calendar = ui.Calendar()
calendar:setGridVisible(true)
calendar:setDate(2026, 8, 19)
calendar:setOnDatePicked(function(sender, date)
    say("Calendar: " .. tostring(date))
end)

-- The compact version, for a form.
local date = ui.DatePicker()
date:setDate(2026, 12, 25)
date:setOnDatePick(function(sender, picked)
    say("DatePicker: " .. tostring(picked))
end)

-- Hour, minute, second -- a time picker holds a time.
local time = ui.TimePicker()
time:setTime(14, 30, 0)
time:setOnTimePicked(function(sender, picked)
    say("TimePicker: " .. tostring(picked))
end)

-- TIMERS ------------------------------------------------------------------
-- Intervals are in milliseconds, unchanged from 1.x.
local ticks = 0
local clock = ui.Label("Timer stopped.")
clock:setTextSize(16)

local timer = sys.Timer()
timer:setInterval(1000)
timer:setOnTimeout(function()
    ticks = ticks + 1
    clock:setText("Tick " .. ticks)
end)

local toggle = ui.Button("Start the timer")
toggle:setOnClick(function(sender)
    if timer:isActive() then
        timer:stop()
        sender:setText("Start the timer")
        clock:setText("Stopped at tick " .. ticks)
    else
        timer:start()
        sender:setText("Stop the timer")
    end
end)

-- A one-shot timer is the way to do something "in a moment" without blocking.
-- The callback is guarded like any other; 1.x's static singleShot connected
-- the raw Lua function to Qt, so an error inside it escaped uncaught.
local later = ui.Button("Say something in 2 seconds")
later:setOnClick(function()
    say("Waiting...")
    sys.Timer.singleShot(2000, function()
        say("...two seconds later.")
    end)
end)

local now = ui.Button("Read the pickers")
now:setOnClick(function()
    say("Now holding: " .. tostring(date:getDate()) .. " at " .. tostring(time:getTime()))
end)

local buttons = ui.HLayout()
buttons:addChild(toggle)
buttons:addChild(later)
buttons:addChild(now)
buttons:addStretch(1)

local form = ui.FormLayout()
form:addChild("Date", date)
form:addChild("Time", time)

local columns = ui.HLayout()
columns:addChild(calendar)

local side = ui.VLayout()
side:addLayout(form)
side:addChild(clock)
side:addStretch(1)
columns:addLayout(side, 1)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(12)
layout:addLayout(columns)
layout:addLayout(buttons)
layout:addChild(ui.HLine())
layout:addChild(report, 1)

window:setLayout(layout)
window:show()
