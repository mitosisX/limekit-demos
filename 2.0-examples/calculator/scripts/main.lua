-- Calculator -- GridLayout and the safe expression evaluator.
--
-- The 1.x calculator called eval(display:getText()). That eval was Python's
-- builtins.eval, injected as a Lua global -- so any string a user could get
-- into the display was arbitrary Python.
--
-- 2.0 does not inject builtins. sys.Expr.evalExpression walks the parsed
-- expression and permits only arithmetic: no attribute access, no calls, no
-- comprehensions, no names. It also bounds ** so 9**9**9 is refused in under
-- a millisecond instead of hanging the process.
--
-- Note the grid is 1-indexed, like every other Limekit coordinate. The 1.x
-- GridLayout took raw 0-based Qt indices while its sibling layouts subtracted
-- one -- the same concept, two conventions, in one framework.

local ui  = require("limekit.ui")
local sys = require("limekit.sys")

local evaluate = sys.Expr.evalExpression

local window = ui.Window { title = "Calculator - Limekit 2.0", size = { 300, 320 } }

local display = ui.TextField("")
display:setReadOnly(true)
display:setTextAlignment("right")
display:setTextSize(18)
display:setResizeRule("expanding", "fixed")

local keys = {
    { "7", "8", "9", "/" },
    { "4", "5", "6", "*" },
    { "1", "2", "3", "-" },
    { "0", ".", "=", "+" },
}

local grid = ui.GridLayout()
grid:setSpacing(6)

for row = 1, #keys do
    for col = 1, #keys[row] do
        local key = keys[row][col]
        local button = ui.Button(key)
        button:setResizeRule("expanding", "expanding")

        if key == "=" then
            button:setOnClick(function()
                local expression = display:getText()
                if expression == "" then return end
                -- evalExpression raises a BridgeError for anything that is
                -- not arithmetic; the guard turns that into a reported error
                -- rather than a crash, so a bad expression is survivable.
                display:setText(evaluate(expression))
            end)
        else
            button:setOnClick(function(self)
                display:setText(display:getText() .. self:getText())
            end)
        end

        grid:addChild(button, row, col)
    end
end

local clear = ui.Button("Clear")
clear:setOnClick(function() display:setText("") end)

local layout = ui.VLayout()
layout:setSpacing(8)
layout:setMargins(12, 12, 12, 12)
layout:addChild(display)
layout:addLayout(grid, 1)
layout:addChild(clear)

window:setLayout(layout)
window:show()
