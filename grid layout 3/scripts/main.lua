window = Window("Grid Layout 2 - Limekit")
window:setIcon(route('app_icon'))
-- window:setSize(200, 200)

mainLayout = GridLayout()

for row = 0, 3 do
	for column = 0, 3 do
		mainLayout:addChild(Button(row..','..column), row, column)
	end
end

window:setLayout(mainLayout)
window:show()