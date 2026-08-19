-- The system tray, and desktop notifications.
--
-- Both wrap the same Qt object, because Qt only offers balloon notifications
-- through a tray icon. Keep a reference to each: they are ordinary values,
-- and a collected tray icon vanishes from the tray.

local ui = require("limekit.ui")

local window = ui.Window { title = "System Tray - Limekit 2.0", size = { 480, 320 } }

local log = ui.TextField()
log:setReadOnly(true)
log:setText("Look for the icon in your system tray.")

local function say(message)
    log:appendText(message)
end

-- Standard icons save shipping a PNG for the obvious cases.
local icon = window:getStandardIcon("SP_ComputerIcon")

-- The tray's right-click menu is an ordinary ui.Menu.
local trayMenu = ui.Menu()

local showItem = ui.MenuItem("Show window")
showItem:setOnClick(function()
    window:show()
    say("Shown from the tray.")
end)

local hideItem = ui.MenuItem("Hide window")
hideItem:setOnClick(function()
    window:hide()
    say("Hidden.")
end)

local quitItem = ui.MenuItem("Quit")
quitItem:setOnClick(function()
    window:close()
end)

trayMenu:addMenuItem(showItem)
trayMenu:addMenuItem(hideItem)
trayMenu:addSeparator()
trayMenu:addMenuItem(quitItem)

local tray = ui.SysTray(icon)
tray:setToolTip("Limekit 2.0 tray example")
tray:setMenu(trayMenu)

tray:setOnActivated(function(sender, reason)
    say("Tray activated (" .. tostring(reason) .. ")")
end)

-- Notifications ------------------------------------------------------------
-- 1.x's setMessage checked isSystemTrayAvailable() and printed "No System
-- Tray available" to the console instead of showing anything, so on a machine
-- without a tray daemon every notification vanished with nothing Lua could
-- see. showMessage always calls through; if the platform cannot show it, that
-- is the platform's answer rather than a silent one.
local notifier = ui.SysNotification(icon)
notifier:setOnClick(function()
    say("Notification clicked.")
end)

local buttons = ui.HLayout()
for _, kind in ipairs({ "information", "warning", "critical", "none" }) do
    local button = ui.Button(kind)
    button:setOnClick(function()
        notifier:showMessage("Limekit", "A " .. kind .. " notification.", kind, 4000)
        say("Sent a " .. kind .. " notification.")
    end)
    buttons:addChild(button)
end

local hide = ui.Button("Hide the window (use the tray to bring it back)")
hide:setOnClick(function()
    window:hide()
end)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(10)
layout:addChild(ui.Label("Notifications:"))
layout:addLayout(buttons)
layout:addChild(hide)
layout:addChild(ui.HLine())
layout:addChild(log, 1)

window:setLayout(layout)
window:show()
