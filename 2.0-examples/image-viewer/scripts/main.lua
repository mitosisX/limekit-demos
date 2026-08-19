-- Images, and how a project finds its own files.
--
-- A Limekit project has images/, scripts/ and misc/ folders, and res.Resources
-- turns a bare filename into the full path -- which matters because the same
-- code has to work from a source checkout and from a frozen executable.
--
--   res.Resources.images("heart.png")   the project's images folder
--   res.Resources.misc("song.mp3")      the project's misc folder
--   res.Resources.route("app_icon")     a name declared in app.json
--
-- Routes are the indirection layer: rename the file, edit app.json, and no
-- Lua changes. Look at this project's app.json for the two shapes.

local ui = require("limekit.ui")
local res = require("limekit.res")

local window = ui.Window {
    title = "Images - Limekit 2.0",
    size = { 720, 560 },
    -- A "single" route: app.json maps app_icon to "images::app.png".
    icon = res.Resources.route("app_icon"),
}

local status = ui.Label("Pick a picture.")
status:setWordWrap(true)

-- THE VIEWER ---------------------------------------------------------------

-- ui.Image is the widget for a picture. setImageSize scales it; calling that
-- before setImage raises rather than doing nothing, because there is no image
-- to size yet.
local viewer = ui.Image()
viewer:setImageAlignment("center")
viewer:setMinHeight(280)

local function display(path, label)
    viewer:setImage(path)
    viewer:setImageSize(260, 260)
    status:setText(label .. "   ->   " .. path)
end

-- A "group" route with a group_label: every item in the group is resolved
-- against the images folder, so the values are bare filenames.
local GALLERY = { "heart", "flag", "food", "portrait" }

local picker = ui.ListBox()
for _, name in ipairs(GALLERY) do
    -- addImageItem puts a thumbnail beside the label.
    picker:addImageItem(name, res.Resources.route("gallery::" .. name))
end

picker:setOnItemSelect(function(sender, text, row)
    display(res.Resources.route("gallery::" .. text), text)
end)

-- A clickable image behaves like a button.
viewer:setOnClick(function()
    status:setText("The picture itself is clickable -- setOnClick works on ui.Image.")
end)

-- A GIF --------------------------------------------------------------------

-- GifPlayer is a separate widget because an animation has a state a still
-- picture does not: frames, a speed, and a play/pause.
local gif = ui.GifPlayer(res.Resources.images("catbot.gif"))
gif:setSize(120, 120)
gif:start()

local gifStatus = ui.Label("")

local playPause = ui.Button("Pause")
playPause:setOnClick(function(sender)
    if sender:getText() == "Pause" then
        gif:pause()
        sender:setText("Play")
    else
        gif:start()
        sender:setText("Pause")
    end
    gifStatus:setText(
        "frame " .. gif:getCurrentFrame() .. " of " .. gif:getFramesCount()
    )
end)

local faster = ui.Button("Faster")
faster:setOnClick(function()
    gif:setSpeed(gif:getSpeed() + 50)
    gifStatus:setText("speed " .. gif:getSpeed() .. "%")
end)

local slower = ui.Button("Slower")
slower:setOnClick(function()
    gif:setSpeed(math.max(10, gif:getSpeed() - 50))
    gifStatus:setText("speed " .. gif:getSpeed() .. "%")
end)

-- A LABEL WITH A PICTURE ----------------------------------------------------

-- ui.Label can hold an image too, which is the lighter option when you only
-- want a decoration and no click handling.
local badge = ui.Label()
badge:setImage(res.Resources.images("app.png"))
badge:setImageSize(48, 48)

-- LAYOUT --------------------------------------------------------------------

local gifControls = ui.HLayout()
gifControls:addChild(playPause)
gifControls:addChild(slower)
gifControls:addChild(faster)
gifControls:addStretch(1)

local gifBox = ui.GroupBox("GifPlayer")
local gifLayout = ui.VLayout()
gifLayout:addChild(gif)
gifLayout:addLayout(gifControls)
gifLayout:addChild(gifStatus)
gifBox:setLayout(gifLayout)

local side = ui.VLayout()
side:addChild(ui.Label("Gallery (routes):"))
side:addChild(picker, 1)
side:addChild(badge)

local main = ui.VLayout()
main:addChild(viewer, 1)
main:addChild(gifBox)

local columns = ui.HLayout()
columns:addLayout(side, 1)
columns:addLayout(main, 2)

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(10)
layout:addLayout(columns, 1)
layout:addChild(ui.HLine())
layout:addChild(status)

display(res.Resources.route("gallery::heart"), "heart")

window:setLayout(layout)
window:show()
