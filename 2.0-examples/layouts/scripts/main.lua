-- Layouts -- how Limekit arranges things.
--
-- There is no absolute positioning here. You nest boxes, and the boxes work
-- out the geometry. Three tools do almost all the work:
--
--   addChild(widget)   put a widget in
--   addLayout(layout)  put another box in, nested
--   addStretch(n)      claim leftover room, so neighbours stop growing

local ui = require("limekit.ui")

local window = ui.Window { title = "Layouts - Limekit 2.0", size = { 620, 420 } }

local root = ui.VLayout()
root:setSpacing(12)
root:setMargins(16, 16, 16, 16)

-- A row. HLayout lays its children left to right.
local toolbar = ui.HLayout()
toolbar:addChild(ui.Button("New"))
toolbar:addChild(ui.Button("Open"))
toolbar:addChild(ui.Button("Save"))
-- Stretch is the trick that pushes the rest of the row to the right. Without
-- it the three buttons would spread out to fill the whole width.
toolbar:addStretch(1)
toolbar:addChild(ui.Button("Help"))

root:addLayout(toolbar)
root:addChild(ui.HLine())

-- Two columns side by side, with the right one twice as wide. The second
-- argument to addLayout is a stretch factor: 1 and 2 means one third / two
-- thirds.
local columns = ui.HLayout()
columns:setSpacing(12)

local left = ui.VLayout()
left:addChild(ui.Label("Sidebar"):setBold(true))
for _, name in ipairs({ "Inbox", "Drafts", "Sent", "Archive" }) do
    left:addChild(ui.Button(name))
end
left:addStretch(1)

local right = ui.VLayout()
right:addChild(ui.Label("Content"):setBold(true))

local body = ui.TextField()
body:setHint("A stretchy widget expands to fill whatever room is left.")
right:addChild(body)

columns:addLayout(left, 1)
columns:addLayout(right, 2)
root:addLayout(columns, 1)

-- A GroupBox is a widget that owns a layout, so it is the tidy way to put a
-- titled border around a cluster of controls.
local options = ui.GroupBox("Spacing demo")
local optionsLayout = ui.HLayout()

optionsLayout:addChild(ui.Label("left"))
-- addSpacing is a fixed gap in pixels; a Spacer is the same idea as a widget
-- you can hold on to and reuse.
optionsLayout:addSpacing(40)
optionsLayout:addChild(ui.Label("40px later"))
optionsLayout:addSpacer(ui.Spacer(80, 1))
optionsLayout:addChild(ui.Label("80px later"))
optionsLayout:addStretch(1)

options:setLayout(optionsLayout)
root:addChild(options)

-- The footer sits at the bottom because the stretch above it ate the slack.
local footer = ui.HLayout()
footer:addStretch(1)
footer:addChild(ui.Button("Cancel"))
footer:addChild(ui.Button("OK"))
root:addLayout(footer)

window:setLayout(root)
window:show()
