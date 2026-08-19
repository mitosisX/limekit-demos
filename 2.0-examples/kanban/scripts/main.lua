-- A kanban board.
--
-- The lesson here is state and persistence. There is one `board` table that
-- is the truth; every view is drawn from it, and every command changes it
-- and then redraws. Nothing edits a widget and hopes the data catches up.
--
-- It saves to JSON on every change, so closing and reopening the app gets
-- you your board back. That round trip -- Lua table to disk and back -- is
-- two calls, and it is the reason writeJSON and readJSON exist rather than
-- leaving you to format it yourself.
--
-- Cards move with buttons rather than by dragging: Limekit does not expose
-- drag and drop yet, and pretending otherwise would make a worse example.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local FS = fs.FileSystem
local System = sys.System

local window = ui.Window { title = "Kanban - Limekit 2.0", size = { 1040, 640 } }

local SAVEFILE = FS.joinPaths(System.getStandardPath("temp"), "limekit-kanban.json")

local COLUMNS = { "Backlog", "In progress", "Review", "Done" }

local STARTER = {
    Backlog = {
        { title = "Write the parser", who = "Ada", size = 5 },
        { title = "Pick a colour scheme", who = "Bea", size = 1 },
        { title = "Survey the competition", who = "Cai", size = 3 },
    },
    ["In progress"] = {
        { title = "Wire up the tree view", who = "Ada", size = 8 },
        { title = "Draft the release notes", who = "Bea", size = 2 },
    },
    Review = {
        { title = "Fix the sorting trap", who = "Cai", size = 3 },
    },
    Done = {
        { title = "Set the project up", who = "Ada", size = 1 },
        { title = "Agree the API", who = "Bea", size = 5 },
    },
}

-- STATE --------------------------------------------------------------------

local board = nil
local status = ui.StatusBar()
window:setStatusbar(status)

local totals = ui.Label("")
status:addPermanentChild(totals)

-- PERSISTENCE --------------------------------------------------------------

local function blankBoard()
    local fresh = {}
    for _, name in ipairs(COLUMNS) do fresh[name] = {} end
    return fresh
end

local function load()
    if not FS.exists(SAVEFILE) then
        -- Copy the starter rather than using it, so "Reset" still has
        -- something pristine to go back to.
        board = blankBoard()
        for name, cards in pairs(STARTER) do
            for _, card in ipairs(cards) do
                table.insert(board[name], { title = card.title, who = card.who, size = card.size })
            end
        end
        return
    end

    local ok, saved = pcall(function() return FS.readJSON(SAVEFILE) end)
    if not ok then
        status:setText("Could not read the saved board: " .. tostring(saved), 6000)
        board = blankBoard()
        return
    end

    -- Trust nothing that came off disk: a hand-edited file is an ordinary
    -- thing to encounter, and it should not take the app down.
    board = blankBoard()
    for _, name in ipairs(COLUMNS) do
        local column = saved[name]
        if type(column) == "table" then
            for _, card in ipairs(column) do
                if type(card) == "table" and card.title then
                    table.insert(board[name], {
                        title = tostring(card.title),
                        who = tostring(card.who or "unassigned"),
                        size = tonumber(card.size) or 1,
                    })
                end
            end
        end
    end
end

local function save()
    local ok, err = pcall(function() FS.writeJSON(SAVEFILE, board, 2) end)
    if not ok then
        status:setText("Could not save: " .. tostring(err), 6000)
    end
end

-- THE VIEWS ----------------------------------------------------------------

local lists = {}                -- column name -> ListBox
local headings = {}             -- column name -> Label

local function label(card)
    return card.title .. "   (" .. card.who .. ", " .. card.size .. ")"
end

local function selected(name)
    local row = lists[name]:getCurrentRow()
    -- 0 is "nothing selected"; Qt would have said -1.
    if row == 0 then return nil end
    return row, board[name][row]
end

local function redraw(keep)
    local grand = 0

    for _, name in ipairs(COLUMNS) do
        local list = lists[name]
        local row = list:getCurrentRow()

        list:clear()
        local points = 0

        for _, card in ipairs(board[name]) do
            list:addItem(label(card))
            points = points + card.size
        end

        grand = grand + points
        headings[name]:setText(name .. "  --  " .. #board[name] .. " cards, " .. points .. " points")

        -- Put the selection back where it was, so acting on a card does not
        -- lose your place in the column.
        if keep == name and row > 0 then
            list:setCurrentRow(math.min(row, #board[name]))
        end
    end

    totals:setText(grand .. " points on the board")
end

local function commit(keep, message)
    redraw(keep)
    save()
    if message then status:setText(message, 4000) end
end

-- THE CARD EDITOR ----------------------------------------------------------
-- A Modal, not a stack of input dialogs: three related fields belong in one
-- form. `open()` blocks until it is dismissed, which is what makes the
-- caller's code read top to bottom.

local function editCard(card, onDone)
    local modal = ui.Modal(card and "Edit card" or "New card", window)
    modal:setSize(380, 240)

    local title = ui.LineEdit(card and card.title or "")
    title:setHint("what needs doing")

    local who = ui.LineEdit(card and card.who or "unassigned")

    local size = ui.Spinner()
    size:setRange(1, 21)
    size:setValue(card and card.size or 1)
    size:setSuffix(" points")

    local form = ui.FormLayout()
    form:addChild("Title", title)
    form:addChild("Owner", who)
    form:addChild("Size", size)

    local ok = ui.Button("Save")
    ok:setOnClick(function()
        local text = title:getText()
        if text == "" then
            -- A dialog on top of a modal is fine; it is parented to the
            -- modal so it centres on the right window.
            ui.Dialogs.warning(modal, "No title", "A card needs a title.")
            return
        end
        onDone({ title = text, who = who:getText(), size = size:getValue() })
        modal:dismiss()
    end)

    local cancel = ui.Button("Cancel")
    cancel:setOnClick(function() modal:dismiss() end)

    local buttons = ui.HLayout()
    buttons:addStretch(1)
    buttons:addChild(cancel)
    buttons:addChild(ok)

    local layout = ui.VLayout()
    layout:setMargins(16, 16, 16, 16)
    layout:addLayout(form)
    layout:addStretch(1)
    layout:addLayout(buttons)

    modal:setLayout(layout)
    modal:open()
end

-- COMMANDS -----------------------------------------------------------------

local function move(name, direction)
    local row, card = selected(name)
    if not card then
        status:setText("Select a card in " .. name .. " first.", 4000)
        return
    end

    local index
    for position, column in ipairs(COLUMNS) do
        if column == name then index = position end
    end

    local target = COLUMNS[index + direction]
    if not target then
        status:setText(direction < 0 and "Already at the first column."
                                     or "Already at the last column.", 4000)
        return
    end

    table.remove(board[name], row)
    table.insert(board[target], card)
    commit(target, card.title .. " -> " .. target)
end

local function reorder(name, direction)
    local row, card = selected(name)
    if not card then return end

    local target = row + direction
    if target < 1 or target > #board[name] then return end

    table.remove(board[name], row)
    table.insert(board[name], target, card)
    redraw()
    lists[name]:setCurrentRow(target)
    save()
end

local function addCard(name)
    editCard(nil, function(card)
        table.insert(board[name], card)
        commit(name, "Added " .. card.title)
    end)
end

local function editSelected(name)
    local row, card = selected(name)
    if not card then
        status:setText("Select a card first.", 4000)
        return
    end
    editCard(card, function(updated)
        board[name][row] = updated
        commit(name, "Updated " .. updated.title)
    end)
end

local function deleteSelected(name)
    local row, card = selected(name)
    if not card then return end
    if not ui.Dialogs.question(window, "Delete", "Delete " .. card.title .. "?") then return end
    table.remove(board[name], row)
    commit(name, "Deleted " .. card.title)
end

-- BUILDING THE COLUMNS -----------------------------------------------------
-- Four identical columns, so they are built in a loop. Each closure captures
-- its own column name, which is what makes the buttons act on the right one.

local function buildColumn(name)
    local column = ui.Container()

    local heading = ui.Label(name)
    heading:setBold(true)
    headings[name] = heading

    local list = ui.ListBox()
    lists[name] = list

    list:setOnItemDoubleClick(function() editSelected(name) end)

    local left = ui.Button("<")
    left:setToolTip("Move to the previous column")
    left:setOnClick(function() move(name, -1) end)

    local right = ui.Button(">")
    right:setToolTip("Move to the next column")
    right:setOnClick(function() move(name, 1) end)

    local up = ui.Button("^")
    up:setToolTip("Move up within this column")
    up:setOnClick(function() reorder(name, -1) end)

    local down = ui.Button("v")
    down:setToolTip("Move down within this column")
    down:setOnClick(function() reorder(name, 1) end)

    local add = ui.Button("+")
    add:setToolTip("Add a card here")
    add:setOnClick(function() addCard(name) end)

    local row = ui.HLayout()
    for _, button in ipairs({ left, right, up, down, add }) do
        button:setMaxWidth(34)
        row:addChild(button)
    end
    row:addStretch(1)

    local layout = ui.VLayout()
    layout:setSpacing(6)
    layout:addChild(heading)
    layout:addChild(list, 1)
    layout:addLayout(row)

    column:setLayout(layout)

    -- The handler gets the row's text and its 1-based position, so there is
    -- no need to go back to the board table just to say what was picked.
    list:setOnItemSelect(function(sender, text, row)
        status:setText(name .. " " .. row .. ": " .. text)
    end)

    return column
end

-- CHROME AND LAYOUT --------------------------------------------------------

local toolbar = ui.Toolbar("Board")
toolbar:setToolButtonStyle("textonly")

local newCard = ui.ToolbarButton("New card")
newCard:setOnClick(function() addCard(COLUMNS[1]) end)
toolbar:addButton(newCard)

local reset = ui.ToolbarButton("Reset the board")
reset:setOnClick(function()
    if not ui.Dialogs.question(window, "Reset", "Throw the board away and start again?") then
        return
    end
    if FS.exists(SAVEFILE) then FS.deleteFile(SAVEFILE) end
    load()
    commit(nil, "Board reset.")
end)
toolbar:addButton(reset)

toolbar:addSeparator()

local whereItLives = ui.ToolbarButton("Where is it saved?")
whereItLives:setOnClick(function()
    ui.Dialogs.info(window, "Saved board",
        "The board is written to:\n\n" .. SAVEFILE ..
        "\n\nIt is rewritten on every change, so closing the app loses nothing.")
end)
toolbar:addButton(whereItLives)

window:addToolbar(toolbar, "top")

-- A Splitter rather than an HLayout, so the columns can be rebalanced.
local columns = ui.Splitter("horizontal")
for _, name in ipairs(COLUMNS) do
    columns:addChild(buildColumn(name))
end
columns:setSizes({ 250, 250, 250, 250 })
columns:setHandleWidth(6)

local root = ui.VLayout()
root:setMargins(10, 10, 10, 10)
root:addChild(columns, 1)

local body = ui.Container()
body:setLayout(root)

load()
redraw()
status:setText("Double-click a card to edit it. Everything is saved as you go.")

window:setMainChild(body)
window:show()
