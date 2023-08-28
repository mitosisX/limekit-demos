-- Creating the window
window = Window("Calculator - Miranda")
window:setIcon(images("calc.png"))
window:setSize(280, 80)

-- Setting the theme
theme = Theme("material")
theme:setTheme("light_blue")

-- Creating the main layout
mainLay = VLayout()
display = TextEdit()
display.setReadOnly(true)
display.setFixedHeight(35)

mainLay:addChild(display)

grid = GridLayout()
mainLay:addLayout(grid)

buttonMap = {}

-- Defining the keyboard layout
keyBoard = {
  {"7", "8", "9", "/", "C"},
  {"4", "5", "6", "*", "("},
  {"1", "2", "3", "-", ")"},
  {"0", "00", ".", "+", "="}
}

-- Populating the grid with buttons
for row = 1, #keyBoard do
  for col = 1, #keyBoard[row] do
    local key = keyBoard[row][col]

    buttonMap[key] = Button(key)
    if key == "C" then
      buttonMap[key]:setMatProperty("danger")
    elseif key == "=" then
      buttonMap[key]:setMatProperty("success")
    end

    grid:addChild(buttonMap[key], row - 1, col - 1)
  end
end

-- Handling button clicks
for keySymbol, button in pairs(buttonMap) do
  if keySymbol ~= "=" and keySymbol ~= "C" then
    button:onClick(function(obj)
      local calText = display:getText()
      local newCalText = calText .. obj:getText()
      display:setText(newCalText)
    end)
  end
end

buttonMap["="]:onClick(function()
  local expression = eval(display:getText())
  display:setText(tostring(expression))
end)
buttonMap["C"]:onClick(function()
  display:setText("")
end)

-- Setting the layout and showing the window
window:setLayout(mainLay)
window:show()
