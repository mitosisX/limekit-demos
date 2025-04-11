
-- 
-- Tic-Tac-Toe (8 April, 2025 11:36am UCT+2, Malawi, Africa)
-- 
-- 				FYI
-- 
-- The style is totally unnecesary, but anyways ;-)
-- 
-- 
-- 


function createTable(size, value)
    local t = {}
    for i = 1, size do
        t[i] = value
    end
    return t
end

currentPlayer = "X"
gameOver = false
board = createTable(9, "")
buttons = {}

local function contains(t, val)
    for i, v in ipairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function highlightWinner()
	winningStyle = [[
        Button {
            font-size: 24px;
            font-weight: bold;
            color: #1E293B; /* Slate-800 */
            background-color: #4fc3f7; /* Sky-100 */
            border: 2px solid #38BDF8; /* Sky-400 */
            border-radius: 10px; /* Rounded corners */
        }
        Button:hover {
            background-color: #BAE6FD; /* Sky-200 */
            border-color: #0EA5E9; /* Sky-500 */
        }
        Button:pressed {
            background-color: #7DD3FC; /* Sky-300 */
            border-color: #0284C7; /* Sky-600 */
        }]]

    for i = 1, 9, 3 do  -- i = 1, 4, 7
        if board[i] ~= "" and 
           board[i] == board[i+1] and 
           board[i+1] == board[i+2] then
           
            -- Highlight winning buttons (adjust for your GUI framework)
            for j = 0, 2 do
                buttons[i+j]:setStyle(winningStyle)
                buttons[i+j]:setEnabled(true)
            end

            return true, board[i]  -- Return true and winning symbol ("X" or "O")
        end
    end

    -- Check columns (for 3 columns: 1,4,7 | 2,5,8 | 3,6,9)
    for i = 1, 3 do  -- i = 1, 2, 3
        if board[i] ~= "" and 
           board[i] == board[i+3] and 
           board[i+3] == board[i+6] then
           
            for j = 0, 6, 3 do  -- j = 0, 3, 6
            	buttons[i+j]:setStyle(winningStyle)
                buttons[i+j]:setEnabled(true)
            end

            return true, board[i]
        end
    end

    -- Check diagonals (1-5-9 and 3-5-7)
    if board[1] ~= "" and board[1] == board[5] and board[5] == board[9] then
        for _, i in ipairs({1, 5, 9}) do
        	buttons[i]:setStyle(winningStyle)
            buttons[i]:setEnabled(true)
        end

        return true, board[1]
    end

    if board[3] ~= "" and board[3] == board[5] and board[5] == board[7] then
        for _, i in ipairs({3, 5, 7}) do
        	button[i]:setStyle(winningStyle)
            buttons[i]:setEnabled(true)
        end

        return true, board[3]
    end

    return false, nil
end

function resetGame()
        currentPlayer = "X"
        board = createTable(9, "")
        gameOver = false
        setPlayerTurnStatus()
        
        for _, button in ipairs(buttons) do
            button:setText("")
            button:setEnabled(true)
            button:setStyle([[
                Button {
		            font-size: 24px;
		            font-weight: bold;
		            color: #333;
		            background-color: #f7f7f7; /* Light gray background */
		            border: 2px solid #4fc3f7; /* Light gray border */
		            border-radius: 10px; /* Rounded corners */
		            padding: 10px; /* Add some padding for better spacing */
		        }
		        Button:hover {
		            background-color: #b3e5fc; /* Lighter gray on hover */
		            border-color: #4fc3f7; /* Darker gray border on hover */
		        }
		        Button:pressed {
		            background-color: #ccc; /* Darker gray on press */
		            border-color: #aaa; /* Even darker gray border on press */
		        }
            ]])
        end
end

function setPlayerTurnStatus()
	statusLabel:setText(string.format("Player %s's turn",currentPlayer))
end

function checkWinner()
    -- Check rows
    for i = 1, 7, 3 do
        if board[i] == board[i+1] and board[i+1] == board[i+2] and board[i] ~= "" then
            return true
        end
    end

    -- Check columns
    for i = 1, 3 do
        if board[i] == board[i+3] and board[i+3] == board[i+6] and board[i] ~= "" then
            return true
        end
    end

    -- Check diagonals
    if board[1] == board[5] and board[5] == board[9] and board[1] ~= "" then
        return true
    end
    if board[3] == board[5] and board[5] == board[7] and board[3] ~= "" then
        return true
    end

    return false
end


function makeMove(position)
	if gameOver or board[position] == true then
		return;
	end

	board[position]=currentPlayer
    buttons[position]:setText(currentPlayer)
	buttons[position]:setEnabled(false)

	if checkWinner() then
		setPlayerTurnStatus()
		gameOver = true
		statusLabel:setText(string.format("Player %s wins!",currentPlayer))
		highlightWinner()

	elseif not contains(board, "") then
		statusLabel:setText("It's a draw!")
		gameOver = true
	else
		currentPlayer = currentPlayer == "X" and "O" or "X"
		setPlayerTurnStatus()
	end
end

function handleMove(position)
	makeMove(position)
end

function partial(func, ...)
    local args = {...}
    return function(...)
        local newArgs = {...}
        for i, arg in ipairs(args) do
            table.insert(newArgs, 1, arg)
        end
        return func(table.unpack(newArgs))
    end
end



window = Window{title='Tic-Tac-Toe -- Limekit', icon = images('app.png'), fixedSize={300, 350}}

mainLay = VLayout()
mainLay:setContentAlignment('center','top')

gameIcon = Label()
gameIcon:setImage(images('game.png'))
gameIcon:resizeImage(40,40)
-- mainLay:addChild(gameIcon)

statusLabel = Label(string.format("Player %s's turn", currentPlayer))
-- app.setFontFile(misc('CeraPro-Regular.ttf'))
statusLabel:setTextAlign('center')
statusLabel:setTextSize(18)
statusLabel:setBold(true)
mainLay:addChild(statusLabel)

gridLay = GridLayout()
gridLay:setSpacing(5)
mainLay:addLayout(gridLay)

for i=1, 9 do
	button = Button("")
	button:setStyle([[
		Button {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            background-color: #f7f7f7; /* Light gray background */
            border: 2px solid #4fc3f7; /* Light gray border */
            border-radius: 10px; /* Rounded corners */
            padding: 10px; /* Add some padding for better spacing */
        }
        Button:hover {
            background-color: #b3e5fc; /* Lighter gray on hover */
            border-color: #4fc3f7; /* Darker gray border on hover */
        }
        Button:pressed {
            background-color: #ccc; /* Darker gray on press */
            border-color: #aaa; /* Even darker gray border on press */
        }
	]])

	button:setFixedSizes(80,80)
	button:setOnClick(partial(handleMove, i))
	table.insert(buttons, button)
	gridLay:addChild(button, math.floor((i - 1) / 3) + 1, (i - 1) % 3 + 1)
end

resetButton = Button("Reset Game")
resetButton:setOnClick(partial(resetGame))
resetButton:setStyle([[
Button {
    padding: 8px;
    font-weight: bold;
    color: #1E293B; /* Slate-800 */
    background-color: #FCE7F3; /* Pink-100 */
    border: 2px solid #F472B6; /* Pink-400 */
    border-radius: 5px; /* Rounded corners */
}
Button:hover {
    background-color: #FBCFE8; /* Pink-200 */
    border-color: #EC4899; /* Pink-500 */
}
Button:pressed {
    background-color: #F9A8D4; /* Pink-300 */
    border-color: #DB2777; /* Pink-600 */
}]])

mainLay:addChild(resetButton)


window:setLayout(mainLay)
window:show()