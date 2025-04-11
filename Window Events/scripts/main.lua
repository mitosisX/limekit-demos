-- Welcome to the new era for modern lua gui development
window = Window{title='Window Events - Limekit', icon = images('app.png'), size={400, 400}}

-- Activated when the mouse is held down and moved across the screen
window:setOnMouseMove(function(sender, pos)
	local x, y = pos.X(), pos.Y()

	label:setText(string.format("Position: X: %d, Y: %d", x, y))
end)

window:setOnMouseRelease(function(sender, mouse)
	label:setText('Status: Released')
end)

-- Activated after single mouse press
window:setOnMousePress(function(sender, mouse)
	if mouse.Left() then
		label:setText('Button: Left')
	elseif mouse.Middle() then
		label:setText('Button: Middle')
	elseif mouse.Right() then
		label:setText('Button: Right')
	end
end)

window:setOnMouseDoubleClick(function(a,event)
	label:setText('Event: Mouse Double Click')
end)

mainLay = VLayout()
mainLay:setContentAlignment('center')

label =Label("Event: nil")
label:setTextSize(15)
mainLay:addChild(label)


window:setLayout(mainLay)

window:show()