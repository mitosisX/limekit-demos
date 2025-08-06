-- Welcome to the new era for modern lua gui development
local theme = app.Theme('qtthemes')


window = Window{title='New app - Limekit', icon = images('app.png'), size={400, 400}}

mainLayout = VLayout()

button = Button("Click me")
mainLayout:addChild(button)

combo = ComboBox()
combo:setItems(theme.getThemes())
combo:setOnItemSelect(function(_, item)
	theme:setTheme(item)
end)

mainLayout:addChild(combo)

window:setLayout(mainLayout)
window:show()