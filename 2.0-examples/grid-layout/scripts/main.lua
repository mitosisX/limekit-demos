-- GridLayout -- rows and columns.
--
-- The one thing to remember: grid coordinates start at 1, like every other
-- index in Limekit 2.0. In 1.x this layout took raw Qt coordinates starting
-- at 0 while the widgets around it counted from 1, which is exactly the kind
-- of quiet inconsistency 2.0 removed.

local ui = require("limekit.ui")

local window = ui.Window { title = "Grid Layout - Limekit 2.0", size = { 480, 340 } }

local grid = ui.GridLayout()
grid:setSpacing(8)
grid:setMargins(16, 16, 16, 16)

-- addChild(widget, row, column) -- top-left is (1, 1).
local heading = ui.Label("A 4x4 grid")
heading:setBold(true)
heading:setTextAlignment("center")

-- The last two arguments span cells: this heading is one row tall and four
-- columns wide.
grid:addChild(heading, 1, 1, 1, 4)

for row = 1, 4 do
    for column = 1, 4 do
        local button = ui.Button(row .. "," .. column)
        button:setToolTip("row " .. row .. ", column " .. column)
        button:setOnClick(function(sender)
            heading:setText("You pressed " .. sender:getText())
        end)
        -- +1 because row 1 is the heading.
        grid:addChild(button, row + 1, column)
    end
end

-- A cell spanning the full width again, to close the grid off.
local footer = ui.Label("Row and column stretch decide who grows when the window does.")
footer:setWordWrap(true)
footer:setTextAlignment("center")
grid:addChild(footer, 6, 1, 1, 4)

-- Stretch factors are per row and per column. Column 4 grows twice as fast
-- as the others; the button rows share the vertical slack evenly.
grid:setColumnStretch(4, 2)
for row = 2, 5 do
    grid:setRowStretch(row, 1)
end

window:setLayout(grid)
window:show()
