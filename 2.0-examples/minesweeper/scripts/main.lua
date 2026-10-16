-- Minesweeper.
--
-- The board is a Lua table; the buttons are only ever a picture of it.
-- Every click changes the table and then `paint` redraws the cells that
-- changed -- the same discipline as the kanban example, applied to a game
-- where the state is a grid.
--
-- Two things make it feel like the real one:
--
--   * The mines are placed on the *first* click, around it, so the first
--     click can never lose.
--   * Revealing an empty cell reveals its neighbours, and theirs, until
--     numbers fence it in -- a flood fill, done with an explicit stack
--     rather than recursion, because an Expert board can open 300 cells
--     at once.
--
-- Limekit buttons report left clicks only, so flags are placed in flag
-- mode: toggle it with the toolbar button or the F key, then click.
-- The clock is a sys.Timer. Best times go to a JSON file in the temp
-- folder.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local window = ui.Window { title = "Minesweeper - Limekit 2.0" }

local SIZES = {
    { name = "Beginner", columns = 9, rows = 9, mines = 10 },
    { name = "Intermediate", columns = 16, rows = 16, mines = 40 },
    { name = "Expert", columns = 30, rows = 16, mines = 99 },
}
local CELL = 26
local BEST_FILE = fs.FileSystem.joinPaths(sys.System.getStandardPath("temp"), "limekit-minesweeper.json")

local NUMBER_COLOURS = { "#1D4ED8", "#15803D", "#DC2626", "#6D28D9", "#B45309", "#0E7490", "#111827", "#6B7280" }

-- STATE ----------------------------------------------------------------------

local size = SIZES[1]
local cells = {}            -- [row][column] = { mine, revealed, flagged, count }
local buttons = {}          -- [row][column] = ui.Button
local started = false       -- mines placed?
local over = false
local flagMode = false
local seconds = 0
local revealed = 0
local flags = 0

local best = {}
do
    local ok, saved = pcall(function() return fs.FileSystem.readJSON(BEST_FILE) end)
    if ok and type(saved) == "table" then best = saved end
end

-- CHROME ---------------------------------------------------------------------

local status = ui.StatusBar()
window:setStatusbar(status)
local minesLabel = ui.Label("")
local clock = ui.LCDNumber()
clock:setDigitCount(3)
clock:setSegmentStyle("flat")
clock:setMaxHeight(26)
status:addPermanentChild(minesLabel)
status:addPermanentChild(clock)

local toolbar = ui.Toolbar()
toolbar:setToolButtonStyle("textbesideicon")
local newButton = ui.ToolbarButton("New game")
local flagButton = ui.ToolbarButton("Flag mode")
flagButton:setCheckable(true)
flagButton:setToolTip("Clicks place flags instead of revealing  (F)")
toolbar:addButton(newButton)
toolbar:addSeparator()
toolbar:addButton(flagButton)
window:addToolbar(toolbar)

local timer = sys.Timer()
timer:setInterval(1000)
timer:setOnTimeout(function()
    seconds = math.min(seconds + 1, 999)
    clock:setValue(seconds)
end)

-- THE BOARD --------------------------------------------------------------------

local function inBounds(r, c)
    return r >= 1 and r <= size.rows and c >= 1 and c <= size.columns
end

local function neighbours(r, c)
    local out = {}
    for dr = -1, 1 do
        for dc = -1, 1 do
            if (dr ~= 0 or dc ~= 0) and inBounds(r + dr, c + dc) then
                out[#out + 1] = { r + dr, c + dc }
            end
        end
    end
    return out
end

local function placeMines(safeRow, safeColumn)
    -- Nothing within one cell of the first click, so it opens an area.
    local forbidden = {}
    forbidden[safeRow * 1000 + safeColumn] = true
    for _, n in ipairs(neighbours(safeRow, safeColumn)) do forbidden[n[1] * 1000 + n[2]] = true end

    local placed = 0
    while placed < size.mines do
        local r, c = math.random(1, size.rows), math.random(1, size.columns)
        if not forbidden[r * 1000 + c] and not cells[r][c].mine then
            cells[r][c].mine = true
            placed = placed + 1
        end
    end
    for r = 1, size.rows do
        for c = 1, size.columns do
            local count = 0
            for _, n in ipairs(neighbours(r, c)) do
                if cells[n[1]][n[2]].mine then count = count + 1 end
            end
            cells[r][c].count = count
        end
    end
    started = true
end

-- PAINTING ---------------------------------------------------------------------

local HIDDEN = "QPushButton { background: #CBD5E1; border: 1px solid #94A3B8; border-radius: 2px; font-weight: bold; }"
    .. "QPushButton:hover { background: #E2E8F0; }"
local OPEN = "QPushButton { background: #F8FAFC; border: 1px solid #E2E8F0; font-weight: bold; color: %s; }"
local MINE = "QPushButton { background: #FCA5A5; border: 1px solid #DC2626; }"
local WRONG = "QPushButton { background: #FDE68A; border: 1px solid #D97706; }"

local function paint(r, c)
    local cell, button = cells[r][c], buttons[r][c]
    if cell.revealed then
        if cell.mine then
            button:setText("✸")
            button:setStyleSheet(MINE)
        else
            button:setText(cell.count > 0 and tostring(cell.count) or "")
            button:setStyleSheet(OPEN:format(NUMBER_COLOURS[cell.count] or "#111"))
        end
    elseif cell.flagged then
        button:setText("⚑")
        button:setStyleSheet(over and not cell.mine and WRONG or HIDDEN)
    else
        button:setText("")
        button:setStyleSheet(HIDDEN)
    end
end

local function paintCounters()
    minesLabel:setText(string.format("Mines: %d   ", size.mines - flags))
end

-- PLAYING ----------------------------------------------------------------------

local function finish(won)
    over = true
    timer:stop()
    for r = 1, size.rows do
        for c = 1, size.columns do
            local cell = cells[r][c]
            if cell.mine and not cell.flagged then cell.revealed = true end
            paint(r, c)
        end
    end
    if won then
        local record = best[size.name]
        local message = "Cleared in " .. seconds .. "s."
        if not record or seconds < record then
            best[size.name] = seconds
            pcall(function() fs.FileSystem.writeJSON(BEST_FILE, best, 2) end)
            message = message .. "  New best time for " .. size.name .. "!"
        else
            message = message .. "  Best: " .. record .. "s."
        end
        status:setText(message)
    else
        status:setText("Boom. New game: toolbar, or N.")
    end
end

local function reveal(startRow, startColumn)
    -- An explicit stack: push a cell, pop it, open it, and if it has no
    -- mines around it push every neighbour. Each cell is opened once.
    local stack = { { startRow, startColumn } }
    while #stack > 0 do
        local top = table.remove(stack)
        local r, c = top[1], top[2]
        local cell = cells[r][c]
        if not cell.revealed and not cell.flagged then
            cell.revealed = true
            revealed = revealed + 1
            paint(r, c)
            if cell.count == 0 then
                for _, n in ipairs(neighbours(r, c)) do
                    if not cells[n[1]][n[2]].revealed then stack[#stack + 1] = n end
                end
            end
        end
    end
end

local function click(r, c)
    if over then return end
    local cell = cells[r][c]
    if flagMode then
        if cell.revealed then return end
        cell.flagged = not cell.flagged
        flags = flags + (cell.flagged and 1 or -1)
        paint(r, c)
        paintCounters()
        return
    end
    if cell.flagged or cell.revealed then return end
    if not started then
        placeMines(r, c)
        timer:start()
    end
    if cell.mine then
        cell.revealed = true
        finish(false)
        return
    end
    reveal(r, c)
    if revealed == size.rows * size.columns - size.mines then
        finish(true)
    end
end

-- BUILDING A BOARD ---------------------------------------------------------------

local grid = ui.GridLayout()
grid:setSpacing(0)
local board = ui.Container()
board:setLayout(grid)

local function newGame(chosen)
    size = chosen or size
    timer:stop()
    started, over, seconds, revealed, flags = false, false, 0, 0, 0
    clock:setValue(0)
    flagMode = false
    flagButton:setChecked(false)

    grid:clear()
    cells, buttons = {}, {}
    for r = 1, size.rows do
        cells[r], buttons[r] = {}, {}
        for c = 1, size.columns do
            cells[r][c] = { mine = false, revealed = false, flagged = false, count = 0 }
            local button = ui.Button("")
            button:setFixedSize(CELL, CELL)
            button:setOnClick(function() click(r, c) end)
            grid:addChild(button, r, c)
            buttons[r][c] = button
        end
    end
    for r = 1, size.rows do for c = 1, size.columns do paint(r, c) end end
    paintCounters()

    -- The window hugs the board: a Beginner board in an Expert-sized
    -- window would be a small grid lost in grey.
    window:setFixedSize(math.max(size.columns * CELL + 24, 360), size.rows * CELL + 110)
    local record = best[size.name]
    status:setText(size.name .. (record and ("  ·  best " .. record .. "s") or "") .. "  ·  F = flags")
end

-- MENU AND KEYS ------------------------------------------------------------------

local menubar = ui.Menubar()
local gameMenu = ui.Menu("&Game")
local newItem = ui.MenuItem("New game")
newItem:setShortcut("N")
newItem:setOnClick(function() newGame() end)
gameMenu:addMenuItem(newItem)
gameMenu:addSeparator()
for _, spec in ipairs(SIZES) do
    local entry = ui.MenuItem(spec.name .. string.format("  (%dx%d, %d mines)", spec.columns, spec.rows, spec.mines))
    entry:setOnClick(function() newGame(spec) end)
    gameMenu:addMenuItem(entry)
end
gameMenu:addSeparator()
-- One function for the key and the button: toggling the button from code
-- flips its check but does not fire its click, so the state is set here.
local function setFlagMode(on)
    flagMode = on
    flagButton:setChecked(on)
    status:setText(on and "Flag mode: clicks place and remove flags." or "Reveal mode.", 3000)
end
local flagItem = ui.MenuItem("Flag mode")
flagItem:setShortcut("F")
flagItem:setOnClick(function() setFlagMode(not flagMode) end)
gameMenu:addMenuItem(flagItem)
local quitItem = ui.MenuItem("Quit")
quitItem:setShortcut("Ctrl+Q")
quitItem:setOnClick(function() window:close() end)
gameMenu:addMenuItem(quitItem)
menubar:addMenu(gameMenu)
window:setMenubar(menubar)

newButton:setOnClick(function() newGame() end)
flagButton:setOnClick(function() setFlagMode(flagButton:isChecked()) end)

-- Stretch either side keeps the grid at its natural size and centred;
-- without it a layout pulls the columns apart to fill the window.
local centred = ui.HLayout()
centred:addStretch()
centred:addChild(board)
centred:addStretch()
local outer = ui.VLayout()
outer:setMargins(12, 12, 12, 12)
outer:addLayout(centred)
outer:addStretch()
window:setLayout(outer)

newGame(SIZES[1])
window:show()
