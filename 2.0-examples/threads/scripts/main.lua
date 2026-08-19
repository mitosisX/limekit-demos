-- Background work, and what it can and cannot do.
--
-- Qt has one absolute rule: only the GUI thread may touch widgets. Break it
-- and you get a crash with no useful message, later, on somebody else's
-- machine. Limekit enforces the rule -- once a sys.Thread has been started,
-- every generated setter checks which thread it is on and raises straight
-- away, so the mistake surfaces at the line that caused it.
--
-- There is a second rule that is Limekit's own, and it is easy to trip over:
-- there is ONE Lua state, shared by every thread. While a worker is running
-- Lua, no other Lua can run -- including your button handlers and any
-- sys.Signal handler the worker fires. The interface keeps repainting,
-- because that is Qt's own C++ code, but your Lua waits its turn.
--
-- The practical rule that falls out of it:
--
--   * a worker is for one long *call* -- a big file, a hash, a shell command
--   * relay() at the end, to say "done", and it arrives promptly
--   * per-step progress relayed from inside a Lua loop does NOT interleave;
--     every update lands in one burst when the worker finishes

local ui = require("limekit.ui")
local sys = require("limekit.sys")
local fs = require("limekit.fs")

local window = ui.Window { title = "Threads - Limekit 2.0", size = { 620, 520 } }

local log = ui.TextField()
log:setReadOnly(true)
log:setText("Nothing running.")

local function say(message)
    log:appendText(message)
end

-- WHAT WORKS ---------------------------------------------------------------
-- One long call off the GUI thread, one signal back when it is over.

local result = ""

local finished = sys.Signal()
finished:setOnSignal(function()
    -- Runs on the GUI thread, so widgets are fair game here.
    say("Worker finished: " .. result)
end)

local hasher = sys.Thread()
hasher:setOnThreadRun(function()
    -- Off the GUI thread. Build up plain Lua values; never touch a widget.
    local text = string.rep("limekit", 200000)
    result = sys.System.makeHash("sha256", text):sub(1, 16) .. "..."
    finished:relay()
end)

local hash = ui.Button("Hash a large string in the background")
hash:setOnClick(function()
    if hasher:isRunning() then
        say("Already running.")
        return
    end
    say("Started hashing...")
    hasher:start()
end)

-- A blocking call that releases the interpreter -- sleeping, waiting on a
-- socket, reading a large file -- is the good case: the GUI stays live for
-- the whole time.
local waiter = sys.Thread()
local waited = sys.Signal()
waited:setOnSignal(function()
    say("...two seconds are up, and the window stayed responsive.")
end)

waiter:setOnThreadRun(function()
    waiter:sleep(2)
    waited:relay()
end)

local wait = ui.Button("Wait two seconds without freezing")
wait:setOnClick(function()
    say("Waiting in the background...")
    waiter:start()
end)

-- WHAT DOES NOT ------------------------------------------------------------

local progress = ui.ProgressBar()
progress:setRange(0, 10)

local step = 0
local tick = sys.Signal()
tick:setOnSignal(function()
    progress:setValue(step)
    say("step " .. step)
end)

local stepper = sys.Thread()
stepper:setOnThreadRun(function()
    for i = 1, 10 do
        step = i
        stepper:sleep(0.2)
        tick:relay()
    end
end)

local drive = ui.Button("Relay progress from a loop (watch it arrive at once)")
drive:setOnClick(function()
    if stepper:isRunning() then return end
    step = 0
    progress:setValue(0)
    say("Ten steps, relaying after each one -- and every update will land together at the end.")
    stepper:start()
end)

-- A timer does what people usually want from that loop: it runs on the GUI
-- thread, in slices, so the interface updates between them.
local timerStep = 0
local ticker = sys.Timer()
ticker:setInterval(200)
ticker:setOnTimeout(function()
    timerStep = timerStep + 1
    progress:setValue(timerStep)
    say("timer step " .. timerStep)
    if timerStep >= 10 then
        ticker:stop()
        say("Timer done -- and you saw each step as it happened.")
    end
end)

local timed = ui.Button("The same ten steps, on a timer (smooth)")
timed:setOnClick(function()
    timerStep = 0
    progress:setValue(0)
    ticker:start()
end)

-- THE AFFINITY GUARD --------------------------------------------------------

local unsafe = sys.Thread()
unsafe:setOnThreadRun(function()
    -- Deliberately wrong: setting a widget from a worker. In 1.x this
    -- "worked" until one day it did not. Here it raises with the property
    -- and the widget named, the error is reported, and the app carries on.
    log:setText("this line should never take effect")
end)

local misbehave = ui.Button("Touch a widget from the wrong thread")
misbehave:setOnClick(function()
    say("Starting a thread that breaks the rule...")
    unsafe:start()
end)

-- Blocking on the GUI thread, for contrast: this one really does freeze.
local block = ui.Button("Sleep on the GUI thread (freezes for 2s)")
block:setOnClick(function()
    say("Freezing...")
    sys.System.sleep(2)
    say("...unfrozen.")
end)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(8)
layout:addChild(progress)
layout:addChild(hash)
layout:addChild(wait)
layout:addChild(ui.HLine())
layout:addChild(drive)
layout:addChild(timed)
layout:addChild(ui.HLine())
layout:addChild(misbehave)
layout:addChild(block)
layout:addChild(log, 1)

window:setOnClose(function()
    -- Never leave a thread running behind a closed window.
    ticker:stop()
    for _, thread in ipairs({ hasher, waiter, stepper, unsafe }) do
        thread:stop()
    end
end)

window:setLayout(layout)
window:show()
