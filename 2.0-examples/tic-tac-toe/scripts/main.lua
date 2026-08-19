-- Tic-tac-toe.
--
-- A whole application in one file: a grid of buttons, game state kept in
-- plain Lua, and an opponent. Nothing framework-specific beyond GridLayout
-- and setOnClick -- the point is that once the widgets are up, the rest is
-- ordinary programming.

local ui = require("limekit.ui")
local sys = require("limekit.sys")

local window = ui.Window { title = "Tic-Tac-Toe - Limekit 2.0", size = { 420, 520 } }

-- STATE ---------------------------------------------------------------------

local board = {}          -- 9 cells: "", "X" or "O"
local buttons = {}        -- the widget for each cell
local human, computer = "X", "O"
local playing = true
local score = { X = 0, O = 0, draws = 0 }

local LINES = {
    { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 },     -- rows
    { 1, 4, 7 }, { 2, 5, 8 }, { 3, 6, 9 },     -- columns
    { 1, 5, 9 }, { 3, 5, 7 },                  -- diagonals
}

local status = ui.Label("Your turn -- you are X.")
status:setTextAlignment("center")
status:setTextSize(14)

local scoreboard = ui.Label("")
scoreboard:setTextAlignment("center")

local function showScore()
    scoreboard:setText("X " .. score.X .. "   O " .. score.O .. "   draws " .. score.draws)
end

-- RULES ---------------------------------------------------------------------

local function winnerOf(cells)
    for _, line in ipairs(LINES) do
        local a, b, c = line[1], line[2], line[3]
        if cells[a] ~= "" and cells[a] == cells[b] and cells[b] == cells[c] then
            return cells[a], line
        end
    end
    return nil
end

local function emptyCells(cells)
    local free = {}
    for index = 1, 9 do
        if cells[index] == "" then table.insert(free, index) end
    end
    return free
end

-- The opponent, in three rules: win if you can, block if you must, otherwise
-- take the centre, then a corner, then anything.
local function computerMove()
    -- Win.
    for _, index in ipairs(emptyCells(board)) do
        board[index] = computer
        if winnerOf(board) == computer then board[index] = "" return index end
        board[index] = ""
    end

    -- Block.
    for _, index in ipairs(emptyCells(board)) do
        board[index] = human
        if winnerOf(board) == human then board[index] = "" return index end
        board[index] = ""
    end

    if board[5] == "" then return 5 end

    local corners = {}
    for _, index in ipairs({ 1, 3, 7, 9 }) do
        if board[index] == "" then table.insert(corners, index) end
    end
    if #corners > 0 then return sys.System.randomChoice(corners) end

    local free = emptyCells(board)
    return #free > 0 and sys.System.randomChoice(free) or nil
end

-- DISPLAY --------------------------------------------------------------------

local function paint()
    for index = 1, 9 do
        local mark = board[index]
        buttons[index]:setText(mark)
        buttons[index]:setEnabled(playing and mark == "")
    end
end

local function highlight(line)
    for _, index in ipairs(line) do
        buttons[index]:setStyleSheet("background: #2d7d46; color: white; font-weight: bold;")
    end
end

local function finish(winner, line)
    playing = false

    if winner then
        score[winner] = score[winner] + 1
        highlight(line)
        status:setText(winner == human and "You win." or "The computer wins.")
    else
        score.draws = score.draws + 1
        status:setText("A draw.")
    end

    showScore()
    paint()
end

local function checkOver()
    local winner, line = winnerOf(board)
    if winner then
        finish(winner, line)
        return true
    end
    if #emptyCells(board) == 0 then
        finish(nil, nil)
        return true
    end
    return false
end

local function play(index)
    if not playing or board[index] ~= "" then return end

    board[index] = human
    paint()
    if checkOver() then return end

    status:setText("Thinking...")

    -- A short pause so the reply does not appear in the same instant as the
    -- click. singleShot runs on the GUI thread, so touching widgets in here
    -- is safe -- and the callback is guarded like any other.
    sys.Timer.singleShot(250, function()
        local move = computerMove()
        if move then
            board[move] = computer
            paint()
        end
        if not checkOver() then
            status:setText("Your turn.")
        end
    end)
end

local function reset()
    for index = 1, 9 do
        board[index] = ""
        if buttons[index] then buttons[index]:setStyleSheet("") end
    end
    playing = true
    status:setText("Your turn -- you are X.")
    paint()
end

-- WIDGETS ---------------------------------------------------------------------

local grid = ui.GridLayout()
grid:setSpacing(6)

for index = 1, 9 do
    board[index] = ""

    local button = ui.Button("")
    button:setMinSize(90, 90)
    button:setStyleSheet("font-size: 34px; font-weight: bold;")
    button:setOnClick(function() play(index) end)

    buttons[index] = button

    -- Cell 1 is the top left. Both coordinates are 1-based.
    local row = math.floor((index - 1) / 3) + 1
    local column = ((index - 1) % 3) + 1
    grid:addChild(button, row, column)
end

local newGame = ui.Button("New game")
newGame:setOnClick(reset)

local resetScore = ui.Button("Reset the score")
resetScore:setOnClick(function()
    score.X, score.O, score.draws = 0, 0, 0
    showScore()
end)

local controls = ui.HLayout()
controls:addChild(newGame)
controls:addChild(resetScore)

local layout = ui.VLayout()
layout:setMargins(20, 20, 20, 20)
layout:setSpacing(12)
layout:addChild(status)
layout:addLayout(grid, 1)
layout:addChild(scoreboard)
layout:addLayout(controls)

showScore()
paint()

window:setLayout(layout)
window:show()
