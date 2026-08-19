-- Dialogs.
--
-- In 1.x these were a dozen loosely related functions on the `app` table --
-- alert, errorDialog, questionPopup, textInput, textInputDialog -- several of
-- which did the same thing under different names. 2.0 collects them on
-- ui.Dialogs with one convention:
--
--   * the parent window comes first, so the dialog centres on it
--   * anything that asks a question returns nil when the user cancels
--
-- Every one of these blocks until the user answers. That is the point of a
-- modal dialog, but it does mean you never call them at startup.

local ui = require("limekit.ui")
local fs = require("limekit.fs")

local window = ui.Window { title = "Dialogs - Limekit 2.0", size = { 520, 460 } }

local log = ui.TextField()
log:setReadOnly(true)
log:setText("Every button opens a dialog. Cancel one to see what nil looks like.")

local function show(label, value)
    if value == nil then
        log:appendText(label .. ": cancelled")
    else
        log:appendText(label .. ": " .. tostring(value))
    end
end

local BUTTONS = {
    -- Messages. These tell rather than ask, so they return nothing.
    { "Info", function()
        ui.Dialogs.info(window, "Information", "Nothing is wrong.")
        show("info", "dismissed")
    end },
    { "Warning", function()
        ui.Dialogs.warning(window, "Careful", "Something might be wrong.")
        show("warning", "dismissed")
    end },
    { "Error", function()
        ui.Dialogs.critical(window, "Failed", "Something is definitely wrong.")
        show("critical", "dismissed")
    end },
    { "Plain alert", function()
        ui.Dialogs.alert(window, "Alert", "A message with no icon.")
        show("alert", "dismissed")
    end },

    -- Questions. A boolean, so check it rather than the truthiness of a string.
    { "Yes / No", function()
        local answer = ui.Dialogs.question(window, "Confirm", "Delete everything?")
        show("question", answer and "yes" or "no")
    end },

    -- Typed input. Each returns nil on cancel -- note that an empty string is
    -- a real answer, so `if text then` and `if text ~= "" then` mean
    -- different things.
    { "Text input", function()
        show("textInput", ui.Dialogs.textInput(window, "Name", "What is your name?", "Ada"))
    end },
    { "Multiline input", function()
        show("multilineInput", ui.Dialogs.multilineInput(window, "Notes", "Anything to add?"))
    end },
    { "Whole number", function()
        show("integerInput", ui.Dialogs.integerInput(window, "Age", "How old?", 30, 0, 150, 1))
    end },
    { "Decimal", function()
        show("doubleInput", ui.Dialogs.doubleInput(window, "Price", "How much?", 9.99, 0, 1000, 2))
    end },
    { "Pick from a list", function()
        show("comboBoxInput", ui.Dialogs.comboBoxInput(
            window, "Language", "Pick one:", { "Lua", "Python", "C" }, 1))
    end },

    -- Files and folders. Filters map a description to its extensions.
    { "Open a file", function()
        local path = ui.Dialogs.openFile(window, "Open", nil, {
            ["Lua scripts"] = { "lua" },
            ["Text files"] = { "txt", "md" },
        })
        if path then
            show("openFile", fs.FileSystem.getFileName(path))
        else
            show("openFile", nil)
        end
    end },
    { "Save a file", function()
        show("saveFile", ui.Dialogs.saveFile(window, "Save as", nil, { ["Text"] = { "txt" } }))
    end },
    { "Pick a folder", function()
        show("pickFolder", ui.Dialogs.pickFolder(window, "Choose a folder"))
    end },

    -- Pickers. These return Qt objects, so hand them straight to a setter
    -- rather than trying to read them apart.
    { "Pick a colour", function()
        local colour = ui.Dialogs.pickColour(window)
        if colour then
            log:setTextColor(colour)
            show("pickColour", "applied")
        else
            show("pickColour", nil)
        end
    end },
    { "Pick a font", function()
        local font = ui.Dialogs.pickFont(window)
        show("pickFont", font and "applied" or nil)
    end },
}

local grid = ui.GridLayout()
grid:setSpacing(6)

for index, spec in ipairs(BUTTONS) do
    local button = ui.Button(spec[1])
    button:setOnClick(spec[2])
    -- Two columns, 1-based: 1,1  1,2  2,1  2,2 ...
    local row = math.floor((index - 1) / 2) + 1
    local column = ((index - 1) % 2) + 1
    grid:addChild(button, row, column)
end

local layout = ui.VLayout()
layout:setMargins(16, 16, 16, 16)
layout:setSpacing(12)
layout:addLayout(grid)
layout:addChild(ui.HLine())
layout:addChild(log, 1)

window:setLayout(layout)
window:show()
